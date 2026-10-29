//! `vic statusline`: the Claude Code status line.
//! Quirks of the bash are copied on purpose (see tools/PROGRESS.md).
use crate::clock;
use crate::error::VicError;
use crate::jq::{self, JqErr};
use serde_json::Value;
use std::fs::{self, File};
use std::io::{Read, Seek, SeekFrom, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

const CTX_LIMIT: u64 = 1_000_000;
const TAIL_LINES: usize = 60;

/// Context fill in percent, or unknown ("?" in the bash).
#[derive(Debug, PartialEq, Clone, Copy)]
enum Ctx {
    Unknown,
    Pct(u64),
}

impl Ctx {
    fn shown(self) -> String {
        match self {
            Ctx::Unknown => "?".into(),
            Ctx::Pct(p) => p.to_string(),
        }
    }
    fn color(self) -> u8 {
        match self {
            Ctx::Unknown => 90,
            Ctx::Pct(p) if p >= 85 => 31,
            Ctx::Pct(p) if p >= 70 => 33,
            Ctx::Pct(_) => 32,
        }
    }
}

fn c(code: u8, text: &str) -> String {
    format!("\x1b[{code}m{text}\x1b[0m")
}

// ---------- stdin fields ----------

#[derive(Default)]
struct Input {
    model: String,
    eff: String,
    cwd: String,
    tr: String,
    cost: String,
}

/// jq `join` element text: null/bool/number/string stringify, containers error.
fn join_text(v: Option<&Value>) -> Result<String, JqErr> {
    match v {
        None | Some(Value::Null) => Ok(String::new()),
        Some(Value::String(s)) => Ok(s.clone()),
        Some(Value::Array(_) | Value::Object(_)) => Err(JqErr),
        Some(other) => Ok(other.to_string()),
    }
}

fn extract(v: &Value) -> Result<Vec<String>, JqErr> {
    let model = jq::alt(v, &[&["model", "display_name"], &["model", "id"]])?;
    let e = jq::path(v, &["effort"])?;
    let e = if e.is_object() {
        jq::path(e, &["level"])?
    } else {
        e
    };
    let eff = Some(e).filter(|x| jq::truthy(x));
    let cwd = jq::alt(v, &[&["workspace", "current_dir"], &["cwd"]])?;
    let tr = jq::alt(v, &[&["transcript_path"]])?;
    let cost = jq::alt(v, &[&["cost", "total_cost_usd"]])?;
    let model_text = match model {
        Some(m) => join_text(Some(m))?,
        None => "?".into(),
    };
    Ok(vec![
        model_text,
        join_text(eff)?,
        join_text(cwd)?,
        join_text(tr)?,
        join_text(cost)?,
    ])
}

/// `IFS='|' read -r model eff cwd tr cost`: first line only, last var takes the rest.
fn parse_input(raw: &[u8]) -> Input {
    let joined = serde_json::from_slice::<Value>(raw)
        .ok()
        .and_then(|v| extract(&v).ok())
        .map(|f| f.join("|"))
        .unwrap_or_default();
    let line = joined.split('\n').next().unwrap_or("");
    let mut it = line.splitn(5, '|').map(str::to_owned);
    Input {
        model: it.next().unwrap_or_default(),
        eff: it.next().unwrap_or_default(),
        cwd: it.next().unwrap_or_default(),
        tr: it.next().unwrap_or_default(),
        cost: it.next().unwrap_or_default(),
    }
}

// ---------- transcript ctx ----------

/// Last `n` lines of a file, like `tail -n N`, reading blocks from the end.
fn tail_bytes(path: &Path, n: usize) -> std::io::Result<Vec<u8>> {
    const BLK: u64 = 65_536;
    let mut f = File::open(path)?;
    let mut pos = f.metadata()?.len();
    let mut buf: Vec<u8> = Vec::new();
    loop {
        let step = BLK.min(pos);
        pos -= step;
        f.seek(SeekFrom::Start(pos))?;
        let mut chunk = vec![0u8; usize::try_from(step).unwrap_or(0)];
        f.read_exact(&mut chunk)?;
        chunk.extend_from_slice(&buf);
        buf = chunk;
        let eff = buf.strip_suffix(b"\n").unwrap_or(&buf);
        let mut idx = Some(eff.len());
        for _ in 0..n {
            idx = idx.and_then(|i| eff[..i].iter().rposition(|&b| b == b'\n'));
        }
        if let Some(i) = idx {
            return Ok(buf[i + 1..].to_vec());
        }
        if pos == 0 {
            return Ok(buf);
        }
    }
}

/// The jq filter over one transcript row; None = row skipped (filtered or jq error).
fn row_tokens(v: &Value) -> Option<String> {
    if jq::path(v, &["type"]).ok()? != "assistant"
        || jq::path(v, &["isSidechain"]).ok()? == &Value::Bool(true)
    {
        return None;
    }
    let usage = jq::path(v, &["message", "usage"]).ok()?;
    if usage.is_null() || !usage.is_object() {
        return None;
    }
    let mut ints: Option<i64> = Some(0);
    let mut float = 0.0;
    for k in [
        "input_tokens",
        "cache_read_input_tokens",
        "cache_creation_input_tokens",
    ] {
        let n = match jq::alt(usage, &[&[k]]).ok()? {
            None => Value::from(0),
            Some(Value::Number(n)) => Value::Number(n.clone()),
            Some(_) => return None,
        };
        float += n.as_f64()?;
        ints = ints.and_then(|s| s.checked_add(n.as_i64()?));
    }
    Some(match ints {
        Some(s) => s.to_string(),
        None if float.fract() == 0.0 && float.abs() < 1e17 => format!("{float:.0}"),
        None => float.to_string(),
    })
}

/// (ctx, tok): tok is the raw last token text, ctx only when it is all digits.
fn transcript_ctx(tr: &str) -> (Ctx, Option<String>) {
    let none = (Ctx::Unknown, None);
    if tr.is_empty() || fs::metadata(tr).map_or(true, |m| m.len() == 0) {
        return none;
    }
    let Ok(bytes) = tail_bytes(Path::new(tr), TAIL_LINES) else {
        return none;
    };
    let text = String::from_utf8_lossy(&bytes);
    // jq stops at the first parse error but keeps what it already emitted
    let tok = serde_json::Deserializer::from_str(&text)
        .into_iter::<Value>()
        .map_while(Result::ok)
        .filter_map(|v| row_tokens(&v))
        .last();
    match tok {
        Some(t) if !t.is_empty() && t.bytes().all(|b| b.is_ascii_digit()) => {
            let pct = t
                .parse::<u64>()
                .map_or(Ctx::Unknown, |n| Ctx::Pct(n * 100 / CTX_LIMIT));
            (pct, Some(t))
        }
        other => (Ctx::Unknown, other),
    }
}

// ---------- quota ----------

struct Quota {
    five: String,
    seven: String,
    r5: String,
    r7: String,
}

fn tsv_cell(v: &Value) -> Result<String, JqErr> {
    match v {
        Value::Number(n) => Ok(n.as_f64().map_or_else(
            || n.to_string(),
            |f| {
                let f = f.floor();
                if f.abs() < 9e15 {
                    format!("{f:.0}")
                } else {
                    f.to_string()
                }
            },
        )),
        Value::String(s) => Ok(s
            .replace('\\', "\\\\")
            .replace('\t', "\\t")
            .replace('\n', "\\n")
            .replace('\r', "\\r")),
        Value::Bool(b) => Ok(b.to_string()),
        _ => Err(JqErr),
    }
}

/// The jq filter over subscription_state.json; Err = jq failed, no output.
fn quota_tsv(root: &Value, now: i64) -> Result<String, JqErr> {
    let l = jq::path(root, &["latest"])?;
    let pct = |w: &str| -> Result<Value, JqErr> {
        Ok(jq::alt(l, &[&[w, "utilization_pct"]])?
            .cloned()
            .unwrap_or_else(|| Value::from("?")))
    };
    let mut items = vec![pct("five_hour")?, pct("seven_day")?];
    // a missing resets_at yields `empty`, which drops the element and shifts the rest
    for w in ["five_hour", "seven_day"] {
        if let Some(r) = jq::alt(l, &[&[w, "resets_at"]])? {
            let t = r.as_str().and_then(clock::parse_iso_z).ok_or(JqErr)?;
            items.push(Value::from(t - now));
        }
    }
    let cells: Result<Vec<String>, JqErr> = items.iter().map(tsv_cell).collect();
    Ok(cells?.join("\t"))
}

/// `IFS=$'\t' read -r a b c d`: tab is whitespace IFS so runs collapse; last var takes the rest.
fn read_tabs(line: &str, vars: usize) -> Vec<String> {
    let mut rest = line
        .split('\n')
        .next()
        .unwrap_or("")
        .trim_start_matches('\t');
    let mut out = Vec::with_capacity(vars);
    while out.len() + 1 < vars {
        match rest.find('\t') {
            Some(i) => {
                out.push(rest[..i].to_owned());
                rest = rest[i..].trim_start_matches('\t');
            }
            None => {
                out.push(rest.to_owned());
                rest = "";
            }
        }
    }
    out.push(rest.trim_end_matches('\t').to_owned());
    out
}

fn read_quota(home: &str, now: i64) -> Quota {
    let defaults = Quota {
        five: "?".into(),
        seven: "?".into(),
        r5: "0".into(),
        r7: "0".into(),
    };
    let sub = PathBuf::from(home).join(".headroom/subscription_state.json");
    if fs::metadata(&sub).map_or(true, |m| m.len() == 0) {
        return defaults;
    }
    // jq failure => `read` gets EOF => all four vars empty
    let line = fs::read(&sub)
        .ok()
        .and_then(|b| serde_json::from_slice::<Value>(&b).ok())
        .and_then(|v| quota_tsv(&v, now).ok())
        .unwrap_or_default();
    let mut f = read_tabs(&line, 4).into_iter();
    Quota {
        five: f.next().unwrap_or_default(),
        seven: f.next().unwrap_or_default(),
        r5: f.next().unwrap_or_default(),
        r7: f.next().unwrap_or_default(),
    }
}

// ---------- burn / dry (the awk programs) ----------

fn dur(s: f64) -> String {
    if s >= 86_400.0 {
        format!(
            "{}d{}h",
            (s / 86_400.0).trunc(),
            ((s % 86_400.0) / 3600.0).trunc()
        )
    } else if s >= 3600.0 {
        format!(
            "{}h{:02}m",
            (s / 3600.0).trunc(),
            ((s % 3600.0) / 60.0).trunc()
        )
    } else {
        format!("{}m", (s / 60.0).trunc())
    }
}

fn digits(p: &str) -> Option<f64> {
    if !p.is_empty() && p.bytes().all(|b| b.is_ascii_digit()) {
        p.parse().ok()
    } else {
        None
    }
}

fn num_or_zero(s: &str) -> f64 {
    if s.is_empty() {
        0.0
    } else {
        s.trim().parse().unwrap_or(0.0)
    }
}

/// "<reset in> <burn>/unit <left> left <hot>"; trailing 0/1 is consumed by `q`.
fn burn(p: &str, r: f64, w: f64, u: f64, unit: &str) -> String {
    let Some(p) = digits(p) else {
        return "?".into();
    };
    if r < 0.0 || r > w {
        return "?".into();
    }
    let e = w - r;
    let t = dur(r);
    if e < 60.0 {
        return t;
    }
    let b = p * u / e;
    let mut s = format!("{t} {b:.1}%/{unit}");
    if p > 0.0 {
        let left = if p >= 100.0 { 0.0 } else { (100.0 - p) * e / p };
        s.push_str(&format!(" {} left", dur(left)));
    }
    s.push_str(&format!(" {}", u8::from(p + b * r / u >= 100.0)));
    s
}

/// Seconds until the 7d quota hits 100% at the burn so far; None = "-".
fn dry(seven: &str, r7: f64) -> Option<i64> {
    let w = 604_800.0;
    let p = digits(seven)?;
    let e = w - r7;
    if r7 < 0.0 || r7 > w || e < 60.0 || p <= 0.0 {
        return None;
    }
    let s = (100.0 - p) * e / p;
    if s >= r7 {
        None
    } else {
        Some(s.trunc() as i64)
    }
}

/// `q`: strip the trailing hot flag, red when it is 1.
fn q(s: &str) -> String {
    if let Some(x) = s.strip_suffix(" 1") {
        c(31, x)
    } else {
        s.strip_suffix(" 0").unwrap_or(s).to_owned()
    }
}

// ---------- subprocess data ----------

/// stdout of a command, stderr dropped; the bool is "exited 0".
fn run_out(prog: &str, args: &[&str]) -> (String, bool) {
    Command::new(prog)
        .args(args)
        .stdin(Stdio::null())
        .stderr(Stdio::null())
        .output()
        .map(|o| {
            (
                String::from_utf8_lossy(&o.stdout).into_owned(),
                o.status.success(),
            )
        })
        .unwrap_or_default()
}

/// awk records: split on '\n', no phantom record after the last newline.
fn records(s: &str) -> Vec<&str> {
    if s.is_empty() {
        vec![]
    } else {
        s.strip_suffix('\n').unwrap_or(s).split('\n').collect()
    }
}

fn fields(rec: &str) -> Vec<&str> {
    rec.split([' ', '\t']).filter(|f| !f.is_empty()).collect()
}

/// gawk strnum: leading/trailing blanks, decimal float, no inf/nan/hex.
fn strnum(f: &str) -> Option<f64> {
    let t = f.trim_matches([' ', '\t']);
    let body = t.strip_prefix(['+', '-']).unwrap_or(t);
    if body.starts_with(|ch: char| ch.is_ascii_digit() || ch == '.') {
        t.parse().ok()
    } else {
        None
    }
}

/// awk `$1 > t` with t a number (strnum) given by -v.
fn after_epoch(first: &str, t: i64) -> bool {
    match strnum(first) {
        Some(n) => n > t as f64,
        None => first > t.to_string().as_str(),
    }
}

fn pm_open(home: &str, pid: u32, now: i64) -> String {
    let dir = std::env::var("XDG_RUNTIME_DIR")
        .ok()
        .filter(|s| !s.is_empty())
        .unwrap_or_else(|| "/tmp".into());
    let cache = PathBuf::from(dir).join("statusline-pm-open");
    let fresh = fs::metadata(&cache)
        .ok()
        .filter(|m| m.is_file())
        .and_then(|m| m.modified().ok())
        .is_some_and(|t| {
            let m = t
                .duration_since(std::time::UNIX_EPOCH)
                .map_or(0, |d| i64::try_from(d.as_secs()).unwrap_or(0));
            now - m <= 60
        });
    if !fresh {
        let bin = std::env::var("VIC_PM")
            .ok()
            .filter(|s| !s.is_empty())
            .unwrap_or_else(|| format!("{home}/hk/vix/modules/vic/ai/vic/bin/vic-pm"));
        let (mut out, ok) = run_out(&bin, &["br", "count", "--status", "open"]);
        if !ok {
            out.push_str("?\n");
        }
        // grep -oE '[0-9]+|\?' | head -1
        let first = out
            .char_indices()
            .find(|(_, ch)| ch.is_ascii_digit() || *ch == '?')
            .map(|(i, ch)| {
                if ch == '?' {
                    "?".to_owned()
                } else {
                    out[i..].chars().take_while(char::is_ascii_digit).collect()
                }
            });
        let tmp = PathBuf::from(format!("{}.{pid}", cache.display()));
        let body = first.map(|f| format!("{f}\n")).unwrap_or_default();
        if fs::write(&tmp, body).is_ok() {
            let _ = fs::rename(&tmp, &cache);
        }
    }
    let pm = fs::read_to_string(&cache).unwrap_or_default();
    let pm = pm.trim_end_matches('\n');
    if pm.is_empty() {
        "?".into()
    } else {
        pm.to_owned()
    }
}

/// (agents in flight, last stop "tier:status").
fn agents(home: &str, cwd: &str, now: i64) -> (u64, String) {
    let starts = PathBuf::from(home)
        .join(".cache/claude-ledger")
        .join(cwd.replace('/', "-"))
        .join("sub-starts");
    let mut ag = 0;
    if starts.is_file() {
        let body = fs::read(&starts)
            .map(|b| String::from_utf8_lossy(&b).into_owned())
            .unwrap_or_default();
        let since = now - 3600;
        let s = records(&body)
            .iter()
            .filter(|r| fields(r).first().is_some_and(|f| after_epoch(f, since)))
            .count() as u64;
        let t = clock::date(&["-d", &format!("@{since}"), "-Is"]);
        let (tele, _) = run_out("vic-telemetry", &["recent", "50"]);
        let e = records(&tele)
            .iter()
            .skip(1)
            .filter(|r| fields(r).first().is_some_and(|f| *f > t.as_str()))
            .count() as u64;
        ag = s.saturating_sub(e);
    }
    let (tele, _) = run_out("vic-telemetry", &["recent", "1"]);
    let last: String = records(&tele)
        .iter()
        .skip(1)
        .map(|r| {
            let f = fields(r);
            let tier = f.get(1).map_or("", |t| t.strip_prefix("vic-").unwrap_or(t));
            format!("{tier}:{}", f.get(5).copied().unwrap_or(""))
        })
        .collect();
    (ag, last)
}

// ---------- render ----------

fn money(cost: &str) -> String {
    format!("{:.2}", cost.trim().parse::<f64>().unwrap_or(0.0))
}

pub(crate) fn run() -> Result<(), VicError> {
    let mut raw = Vec::new();
    std::io::stdin().read_to_end(&mut raw)?;
    let inp = parse_input(&raw);
    let home = std::env::var("HOME").unwrap_or_default();
    let cwd = if inp.cwd.is_empty() {
        std::env::var("PWD")
            .ok()
            .or_else(|| {
                std::env::current_dir()
                    .ok()
                    .map(|d| d.to_string_lossy().into_owned())
            })
            .unwrap_or_default()
    } else {
        inp.cwd.clone()
    };
    let now = clock::now_epoch();
    let (ctx, tok) = transcript_ctx(&inp.tr);
    let qt = read_quota(&home, now);
    let b5 = burn(&qt.five, num_or_zero(&qt.r5), 18_000.0, 3600.0, "h");
    let b7 = burn(&qt.seven, num_or_zero(&qt.r7), 604_800.0, 86_400.0, "d");
    let dry_s = dry(&qt.seven, num_or_zero(&qt.r7));
    let pm = pm_open(&home, std::process::id(), now);
    let (ag, last) = agents(&home, &cwd, now);

    // `[ "$seven" -ge 90 ]` errors (colour unchanged) when not an integer
    let sc = if qt.seven == "?" {
        90
    } else if qt.seven.trim().parse::<i64>().is_ok_and(|n| n >= 90) {
        31
    } else {
        35
    };
    let mut o = c(36, &inp.model);
    if !inp.eff.is_empty() {
        o.push(' ');
        o.push_str(&c(90, &inp.eff));
    }
    o.push_str(&format!(
        " · ctx {} · 5h {} {} · 7d {} {}",
        c(ctx.color(), &format!("{}%", ctx.shown())),
        c(34, &format!("{}%", qt.five)),
        q(&b5),
        c(sc, &format!("{}%", qt.seven)),
        q(&b7)
    ));
    if let Some(d) = dry_s {
        let when = clock::date(&["-d", &format!("+{d} seconds"), "+%a %H:%M"]);
        o.push(' ');
        o.push_str(&c(31, &when));
    }
    if !inp.cost.is_empty() {
        o.push_str(&format!(" · {}", c(93, &format!("${}", money(&inp.cost)))));
    }
    if let Some(k) = tok.as_deref().and_then(|t| t.parse::<i64>().ok()) {
        o.push(' ');
        o.push_str(&c(34, &format!("{}k", k / 1000)));
    }
    o.push_str(&format!(" · PM {}", c(36, &pm)));
    o.push_str(&format!(" · ag {ag}"));
    if !last.is_empty() {
        o.push(' ');
        o.push_str(&c(90, &last));
    }
    o.push('\n');
    std::io::stdout().write_all(o.as_bytes())?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn ctx_bands() {
        assert_eq!(Ctx::Pct(69).color(), 32);
        assert_eq!(Ctx::Pct(70).color(), 33);
        assert_eq!(Ctx::Pct(85).color(), 31);
        assert_eq!(Ctx::Unknown.color(), 90);
    }

    #[test]
    fn burn_shapes() {
        assert_eq!(burn("x", 0.0, 18_000.0, 3600.0, "h"), "?");
        assert_eq!(burn("50", 17_990.0, 18_000.0, 3600.0, "h"), "4h59m");
        assert_eq!(
            burn("50", 9_000.0, 18_000.0, 3600.0, "h"),
            "2h30m 20.0%/h 2h30m left 1"
        );
    }

    #[test]
    fn dry_none_when_lasts() {
        assert_eq!(dry("10", 100_000.0), None);
        assert!(dry("90", 500_000.0).is_some());
    }

    #[test]
    fn q_strips_flag() {
        assert_eq!(q("1h 0"), "1h");
        assert_eq!(q("1h 1"), "\x1b[31m1h\x1b[0m");
        assert_eq!(q("?"), "?");
    }

    #[test]
    fn read_tabs_collapses() {
        assert_eq!(read_tabs("a\t\tb", 4), vec!["a", "b", "", ""]);
    }

    #[test]
    fn missing_resets_shifts_fields() {
        let v = json!({"latest":{"five_hour":{"utilization_pct":5.0},"seven_day":{"utilization_pct":6.0,"resets_at":"2026-10-29T20:00:00Z"}}});
        assert_eq!(
            quota_tsv(&v, 1_793_304_000 - 10).ok().as_deref(),
            Some("5\t6\t10")
        );
    }

    #[test]
    fn row_tokens_sums_and_skips() {
        let ok = json!({"type":"assistant","message":{"usage":{"input_tokens":1,"cache_read_input_tokens":2}}});
        assert_eq!(row_tokens(&ok).as_deref(), Some("3"));
        let side = json!({"type":"assistant","isSidechain":true,"message":{"usage":{}}});
        assert_eq!(row_tokens(&side), None);
    }

    #[test]
    fn input_pipe_split() {
        let i = parse_input(br#"{"model":{"display_name":"M"},"cost":{"total_cost_usd":0}}"#);
        assert_eq!((i.model.as_str(), i.cost.as_str()), ("M", "0"));
    }
}
