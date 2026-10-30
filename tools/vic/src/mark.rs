//! `vic hook mark` (Stop, SubagentStop, PreCompact): queue the transcript for the
//! learner. Never blocks, never prints, exit 0 always.
use crate::clock;
use serde_json::{json, Value};
use std::fs::{self, OpenOptions};
use std::io::{Read, Write};
use std::path::PathBuf;

fn queue_line(input: &[u8], ts: &str) -> Option<String> {
    let v: Value = serde_json::from_slice(input).ok()?;
    let s = |k: &str| v.get(k).and_then(Value::as_str).unwrap_or("");
    let path = s("transcript_path");
    let bytes = fs::metadata(path).map_or(0, |m| m.len());
    Some(
        json!({"ts": ts, "event": s("hook_event_name"), "session_id": s("session_id"),
               "transcript_path": path, "bytes": bytes})
        .to_string(),
    )
}

pub(crate) fn run() -> i32 {
    let mut raw = Vec::new();
    if std::io::stdin().read_to_end(&mut raw).is_err() {
        return 0;
    }
    let Some(line) = queue_line(&raw, &clock::iso_utc(clock::now_epoch())) else {
        return 0;
    };
    let Some(home) = std::env::var_os("HOME") else {
        return 0;
    };
    let dir = PathBuf::from(home).join(".cache/vic");
    if fs::create_dir_all(&dir).is_err() {
        return 0;
    }
    if let Ok(mut f) = OpenOptions::new()
        .create(true)
        .append(true)
        .open(dir.join("learn-queue.jsonl"))
    {
        let _ = f.write_all(format!("{line}\n").as_bytes());
    }
    0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn line_has_fields_and_size() {
        let line = queue_line(
            br#"{"hook_event_name":"Stop","session_id":"s","transcript_path":"/nonexistent"}"#,
            "T",
        )
        .unwrap_or_default();
        assert_eq!(
            line,
            r#"{"ts":"T","event":"Stop","session_id":"s","transcript_path":"/nonexistent","bytes":0}"#
        );
    }

    #[test]
    fn garbage_is_none() {
        assert_eq!(queue_line(b"nope", "T"), None);
    }
}
