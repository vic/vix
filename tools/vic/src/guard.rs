//! `vic hook guard`: PreToolUse(Bash) refusals. Exit 2 + stderr = refuse.
//! grep is line-based, so every pattern is tested per line (never across '\n').
use crate::error::VicError;
use crate::jq;
use regex::Regex;
use std::io::Read;
use std::path::Path;

/// Command position: line start or after ; & | ( ` $(, past env assignments and sudo/env.
const AT: &str = r"(?:^|[;&|(`]|\$\()[[:space:]]*(?:(?:[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*|sudo|env)[[:space:]]+)*";
const FLAG_F: &str = r"[[:space:]](?:[^;&|]*[[:space:]])?(?:-[a-zA-Z]*f|--full)";

const JJ_REFUSAL: &str = "Refused: this repo uses jj. Use the jj equivalent (jj commit / jj new / jj squash / jj restore / jj rebase).";

/// Mutating git subcommands (LOCAL REPO LAW); read-only git passes.
const GIT_MUTATING: &str =
    "commit|add|stash|checkout|switch|reset|rebase|merge|restore|cherry-pick";

/// True when `cwd` or any ancestor holds a `.jj`.
fn in_jj_repo(cwd: &Path) -> bool {
    cwd.ancestors().any(|d| d.join(".jj").exists())
}

#[derive(Debug, PartialEq)]
pub(crate) enum Verdict {
    Allow,
    Refuse(String),
}

fn any_line(re: &Regex, text: &str) -> bool {
    text.split('\n').any(|l| re.is_match(l))
}

pub(crate) fn check(cmd: &str, cwd: Option<&Path>) -> Result<Verdict, VicError> {
    if cmd.is_empty() {
        return Ok(Verdict::Allow);
    }
    if any_line(&Regex::new(&format!("{AT}pkill{FLAG_F}"))?, cmd) {
        return Ok(Verdict::Refuse("Refused: pkill -f matches its own shell and has killed the orchestrator. Kill only a PID captured with $! at launch.".into()));
    }
    let flat = cmd.replace('\n', " ");
    let pgrep = Regex::new(&format!(r"(?:while|until)[[:space:]].*pgrep{FLAG_F}"))?;
    if pgrep.is_match(&flat) {
        return Ok(Verdict::Refuse("Refused: a pgrep -f wait loop matches its own command line and never ends. Wait on a $! PID (while kill -0 $pid) or a producer-written marker, under timeout.".into()));
    }
    let capped = Regex::new(r"timeout[[:space:]]|MemoryMax=")?;
    let nix = Regex::new(&format!(
        r"{AT}nix[[:space:]]+(?:eval|build|flake[[:space:]]+check)(?:[[:space:]]|$)"
    ))?;
    if !any_line(&capped, cmd) && any_line(&nix, cmd) {
        return Ok(Verdict::Refuse(format!("Refused: uncapped nix eval/build. Re-run as: timeout 300 {cmd}\n(or systemd-run --user --scope -q -p MemoryMax=12G {cmd}; rc 124/137 is a finding, never re-run uncapped.)")));
    }
    let git = Regex::new(&format!(
        r"{AT}git[[:space:]]+(?:{GIT_MUTATING})(?:[[:space:]]|$)"
    ))?;
    if any_line(&git, cmd) && cwd.is_some_and(in_jj_repo) {
        return Ok(Verdict::Refuse(JJ_REFUSAL.into()));
    }
    Ok(Verdict::Allow)
}

/// `jq -r '.tool_input.command // empty'` then `$(...)`, plus `.cwd`; fail-open on any error.
fn command_of(raw: &[u8]) -> Option<(String, Option<String>)> {
    let v: serde_json::Value = serde_json::from_slice(raw).ok()?;
    let c = jq::alt(&v, &[&["tool_input", "command"]]).ok()??;
    let cwd = match jq::path(&v, &["cwd"]) {
        Ok(serde_json::Value::String(s)) if !s.is_empty() => Some(s.clone()),
        _ => None,
    };
    Some((jq::tostring(c).trim_end_matches('\n').to_owned(), cwd))
}

/// Returns the process exit code.
pub(crate) fn run() -> i32 {
    let mut raw = Vec::new();
    if std::io::stdin().read_to_end(&mut raw).is_err() {
        return 0;
    }
    let Some((cmd, cwd)) = command_of(&raw) else {
        return 0;
    };
    match check(&cmd, cwd.as_deref().map(Path::new)) {
        Ok(Verdict::Refuse(m)) => {
            eprintln!("{m}");
            2
        }
        Ok(Verdict::Allow) | Err(_) => 0,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    use std::path::PathBuf;

    fn refused(c: &str) -> bool {
        matches!(check(c, None), Ok(Verdict::Refuse(_)))
    }

    /// Temp tree: `<tmp>/vic-guard-<pid>-<tag>/{jj/.jj, jj/sub, plain}`.
    fn fixture(tag: &str) -> (PathBuf, PathBuf) {
        let root = std::env::temp_dir().join(format!("vic-guard-{}-{tag}", std::process::id()));
        let jj = root.join("jj");
        let plain = root.join("plain");
        let _ = std::fs::create_dir_all(jj.join(".jj"));
        let _ = std::fs::create_dir_all(jj.join("sub"));
        let _ = std::fs::create_dir_all(&plain);
        (jj, plain)
    }

    #[test]
    fn git_mutating_refused_in_jj() {
        let (jj, _) = fixture("a");
        let sub = jj.join("sub");
        for c in [
            "git commit -m x",
            "cd x && git add .",
            "sudo git stash",
            "git cherry-pick abc",
            "git rebase main",
        ] {
            assert_eq!(
                check(c, Some(&sub)).ok(),
                Some(Verdict::Refuse(JJ_REFUSAL.into())),
                "{c}"
            );
        }
    }

    #[test]
    fn git_allowed_without_jj_or_readonly() {
        let (jj, plain) = fixture("b");
        assert_eq!(
            check("git commit -m x", Some(&plain)).ok(),
            Some(Verdict::Allow)
        );
        assert_eq!(check("git commit -m x", None).ok(), Some(Verdict::Allow));
        for c in [
            "git log",
            "git status",
            "git diff",
            "jj commit -m x",
            "echo git commit",
        ] {
            assert_eq!(check(c, Some(&jj)).ok(), Some(Verdict::Allow), "{c}");
        }
    }

    #[test]
    fn pkill_f() {
        assert!(refused("pkill -f foo"));
        assert!(refused("a; sudo pkill -xf x"));
        assert!(!refused("echo pkill -f"));
    }

    #[test]
    fn pgrep_loop() {
        assert!(refused("while pgrep -f x; do sleep 1; done"));
        assert!(!refused("pgrep -f x"));
    }

    #[test]
    fn nix_uncapped() {
        assert!(refused("nix build .#x"));
        assert!(refused("FOO=1 nix flake check"));
        assert!(!refused("timeout 300 nix build .#x"));
        assert!(!refused("nix develop"));
    }

    #[test]
    fn nix_message_has_cmd() {
        let want = "Refused: uncapped nix eval/build. Re-run as: timeout 300 nix eval .#a\n(or systemd-run --user --scope -q -p MemoryMax=12G nix eval .#a; rc 124/137 is a finding, never re-run uncapped.)";
        assert_eq!(
            check("nix eval .#a", None).ok(),
            Some(Verdict::Refuse(want.into()))
        );
    }
}
