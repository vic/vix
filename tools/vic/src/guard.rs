//! `vic hook guard`: port of hooks/bash-guard.sh. Exit 2 + stderr = refuse.
//! grep is line-based, so every pattern is tested per line (never across '\n').
use crate::error::VicError;
use crate::jq;
use regex::Regex;
use std::io::Read;

/// Command position: line start or after ; & | ( ` $(, past env assignments and sudo/env.
const AT: &str = r"(?:^|[;&|(`]|\$\()[[:space:]]*(?:(?:[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*|sudo|env)[[:space:]]+)*";
const FLAG_F: &str = r"[[:space:]](?:[^;&|]*[[:space:]])?(?:-[a-zA-Z]*f|--full)";

#[derive(Debug, PartialEq)]
pub(crate) enum Verdict {
    Allow,
    Refuse(String),
}

fn any_line(re: &Regex, text: &str) -> bool {
    text.split('\n').any(|l| re.is_match(l))
}

pub(crate) fn check(cmd: &str) -> Result<Verdict, VicError> {
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
    Ok(Verdict::Allow)
}

/// `jq -r '.tool_input.command // empty'` then `$(...)`; fail-open on any error.
fn command_of(raw: &[u8]) -> Option<String> {
    let v: serde_json::Value = serde_json::from_slice(raw).ok()?;
    let c = jq::alt(&v, &[&["tool_input", "command"]]).ok()??;
    Some(jq::tostring(c).trim_end_matches('\n').to_owned())
}

/// Returns the process exit code.
pub(crate) fn run() -> i32 {
    let mut raw = Vec::new();
    if std::io::stdin().read_to_end(&mut raw).is_err() {
        return 0;
    }
    let Some(cmd) = command_of(&raw) else {
        return 0;
    };
    match check(&cmd) {
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

    fn refused(c: &str) -> bool {
        matches!(check(c), Ok(Verdict::Refuse(_)))
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
            check("nix eval .#a").ok(),
            Some(Verdict::Refuse(want.into()))
        );
    }
}
