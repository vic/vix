//! `vic hook ledger`: PostToolUse(Bash) cmd + output ledger. Fail-open, zero stdout.
use crate::clock;
use crate::jq::{self, JqErr};
use serde_json::Value;
use std::fs::{self, OpenOptions};
use std::io::{Read, Write};
use std::path::PathBuf;

const OUT_MAX: usize = 60_000;
const ERR_MAX: usize = 8_000;

/// Project key: the project dir with '/' turned into '-' (bash `sed 's|/|-|g'`).
struct ProjectKey(String);

impl ProjectKey {
    fn from_dir(p: &str) -> Self {
        ProjectKey(p.replace('/', "-"))
    }
}

/// The jq program, line for line. Err = jq runtime error = nothing written.
fn build_line(v: &Value, ts: &str) -> Result<String, JqErr> {
    let sid = jq::alt(v, &[&["session_id"]])?
        .cloned()
        .unwrap_or_else(|| Value::from("?"));
    let cmd = jq::alt(v, &[&["tool_input", "command"]])?
        .cloned()
        .unwrap_or_else(|| Value::from(""));
    let out = match jq::alt(
        v,
        &[&["tool_response", "stdout"], &["tool_response", "output"]],
    )? {
        Some(x) => x.clone(),
        None => Value::from(jq::tostring(jq::path(v, &["tool_response"])?)),
    };
    let out = jq::slice(&out, OUT_MAX)?;
    let err = jq::alt(v, &[&["tool_response", "stderr"]])?
        .cloned()
        .unwrap_or_else(|| Value::from(""));
    let err = jq::slice(&err, ERR_MAX)?;
    Ok(format!(
        "{{\"ts\":{},\"sid\":{},\"cmd\":{},\"out\":{},\"err\":{}}}",
        jq::compact(&Value::from(ts)),
        jq::compact(&sid),
        jq::compact(&cmd),
        jq::compact(&out),
        jq::compact(&err)
    ))
}

fn ledger_dir() -> Option<PathBuf> {
    let home = std::env::var_os("HOME")?;
    let p = std::env::var("CLAUDE_PROJECT_DIR")
        .ok()
        .filter(|s| !s.is_empty())
        .or_else(|| std::env::var("PWD").ok())
        .or_else(|| {
            std::env::current_dir()
                .ok()
                .map(|d| d.to_string_lossy().into_owned())
        })?;
    let key = ProjectKey::from_dir(&p);
    Some(PathBuf::from(home).join(".cache/claude-ledger").join(key.0))
}

/// Returns the process exit code (always 0).
pub(crate) fn run() -> i32 {
    let Some(dir) = ledger_dir() else { return 0 };
    if fs::create_dir_all(&dir).is_err() {
        return 0;
    }
    // bash opens (creates) the file before jq runs, so it exists even when jq fails.
    // shortcut: local date via `date`, see clock.rs.
    let day = clock::date(&["+%Y%m%d"]);
    let Ok(mut f) = OpenOptions::new()
        .create(true)
        .append(true)
        .open(dir.join(format!("bash-{day}.jsonl")))
    else {
        return 0;
    };
    let mut raw = Vec::new();
    if std::io::stdin().read_to_end(&mut raw).is_err() {
        return 0;
    }
    let Ok(v) = serde_json::from_slice::<Value>(&raw) else {
        return 0;
    };
    if let Ok(line) = build_line(&v, &clock::iso_utc(clock::now_epoch())) {
        // one write call so concurrent appenders do not interleave
        let _ = f.write_all(format!("{line}\n").as_bytes());
    }
    0
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn full_line() {
        let v = json!({"session_id":"s","tool_input":{"command":"ls"},"tool_response":{"stdout":"a","stderr":"b"}});
        assert_eq!(
            build_line(&v, "T").ok().as_deref(),
            Some(r#"{"ts":"T","sid":"s","cmd":"ls","out":"a","err":"b"}"#)
        );
    }

    #[test]
    fn string_response_is_jq_error() {
        let v = json!({"tool_response":"str"});
        assert!(build_line(&v, "T").is_err());
    }

    #[test]
    fn missing_response_is_null_string() {
        let v = json!({});
        assert_eq!(
            build_line(&v, "T").ok().as_deref(),
            Some(r#"{"ts":"T","sid":"?","cmd":"","out":"null","err":""}"#)
        );
    }

    #[test]
    fn key_replaces_slashes() {
        assert_eq!(ProjectKey::from_dir("/a/b").0, "-a-b");
    }
}
