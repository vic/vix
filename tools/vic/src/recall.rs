//! `vic recall build` (quipu ledger -> JSON cache) and `vic hook recall`
//! (cache -> top-3 lessons as additionalContext). The hook never touches quipu.
//!
//! `quipu read` TSV, measured on a db copy (87 rows): header `l\tc`, a dashes
//! line, rows `"label"<TAB>"text"`, blank line, `N results`. Values are NOT
//! escaped: inner double quotes stay raw, a newline inside a value is a real
//! line break (the next line is a continuation), `\n` typed in the source stays
//! the two characters backslash-n, and no value held a tab. So a row starts at
//! a line beginning `"ledger:`, the label ends at the first `"<TAB>"`, and the
//! text runs to the last `"` before the next row start.
use crate::error::VicError;
use serde_json::{json, Value};
use std::collections::HashSet;
use std::fs;
use std::io::Read;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

const SPARQL: &str = "SELECT ?l ?c WHERE { ?e <http://www.w3.org/2000/01/rdf-schema#label> ?l ; <http://www.w3.org/2000/01/rdf-schema#comment> ?c . FILTER(STRSTARTS(STR(?l),\"ledger:\")) }";
const CAP: usize = 600;
const ITEM_CHARS: usize = 160;
const HEADER: &str = "QUIPU RECALL (verify before use): ";
const STOP: &[&str] = &[
    "this", "that", "with", "from", "have", "will", "your", "what", "when", "then", "than", "them",
    "they", "there", "here", "about", "into", "also", "just", "does", "need", "should", "would",
    "could", "been", "were", "which", "while", "where", "make", "like", "some", "more", "only",
];

#[derive(Debug, Clone, PartialEq)]
pub(crate) struct Project(String);

impl Project {
    fn new(s: &str) -> Option<Self> {
        (!s.is_empty()).then(|| Project(s.to_owned()))
    }
}

#[derive(Debug, Clone, PartialEq)]
pub(crate) enum Kind {
    Mistake,
    Evidence,
    Ruling,
    Decision,
    Landed,
    Bead,
    Handoff,
    State,
    Other(String),
}

impl Kind {
    fn parse(s: &str) -> Self {
        match s {
            "mistake" => Kind::Mistake,
            "evidence" => Kind::Evidence,
            "ruling" => Kind::Ruling,
            "decision" => Kind::Decision,
            "landed" => Kind::Landed,
            "bead" => Kind::Bead,
            "handoff" => Kind::Handoff,
            "state" => Kind::State,
            other => Kind::Other(other.to_owned()),
        }
    }

    fn as_str(&self) -> &str {
        match self {
            Kind::Mistake => "mistake",
            Kind::Evidence => "evidence",
            Kind::Ruling => "ruling",
            Kind::Decision => "decision",
            Kind::Landed => "landed",
            Kind::Bead => "bead",
            Kind::Handoff => "handoff",
            Kind::State => "state",
            Kind::Other(s) => s,
        }
    }

    /// Weight in halves: 2.0 -> 4, 1.0 -> 2, 0.5 -> 1.
    fn weight(&self) -> usize {
        match self {
            Kind::Mistake | Kind::Ruling => 4,
            Kind::Evidence | Kind::Decision => 2,
            _ => 1,
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub(crate) struct Lesson {
    project: Project,
    kind: Kind,
    slug: String,
    text: String,
}

impl Lesson {
    fn label(&self) -> String {
        format!(
            "ledger:{}/{}/{}",
            self.project.0,
            self.kind.as_str(),
            self.slug
        )
    }
}

/// `ledger:<project>/<kind>/<slug>`; every part non-empty.
fn parse_label(label: &str) -> Option<(Project, Kind, String)> {
    let mut it = label.strip_prefix("ledger:")?.splitn(3, '/');
    let (p, k, s) = (it.next()?, it.next()?, it.next()?);
    if k.is_empty() || s.is_empty() {
        return None;
    }
    Some((Project::new(p)?, Kind::parse(k), s.to_owned()))
}

fn parse_row(first: &str, rest: &[&str]) -> Option<(String, String)> {
    let (label, tail) = first.strip_prefix('"')?.split_once("\"\t\"")?;
    let mut text = tail.to_owned();
    for l in rest {
        text.push('\n');
        text.push_str(l);
    }
    text.strip_suffix('"')
        .map(|t| (label.to_owned(), t.to_owned()))
}

/// Returns (lessons, skipped).
pub(crate) fn parse_tsv(out: &str) -> (Vec<Lesson>, usize) {
    let mut lines: Vec<&str> = out.lines().collect();
    while lines.last().is_some_and(|l| l.trim().is_empty()) {
        lines.pop();
    }
    if lines.last().is_some_and(|l| {
        l.strip_suffix(" results")
            .is_some_and(|n| n.parse::<u64>().is_ok())
    }) {
        lines.pop();
        while lines.last().is_some_and(|l| l.trim().is_empty()) {
            lines.pop();
        }
    }
    let body: &[&str] = match lines.iter().position(|l| l.starts_with("---")) {
        Some(i) => &lines[i + 1..],
        None => &[],
    };
    let starts: Vec<usize> = (0..body.len())
        .filter(|&i| body[i].starts_with("\"ledger:"))
        .collect();
    let mut lessons = Vec::new();
    let mut skipped = 0;
    for (n, &s) in starts.iter().enumerate() {
        let end = starts.get(n + 1).copied().unwrap_or(body.len());
        let parsed = parse_row(body[s], &body[s + 1..end]).and_then(|(l, text)| {
            parse_label(&l).map(|(project, kind, slug)| (project, kind, slug, text))
        });
        match parsed {
            Some((project, kind, slug, text)) => lessons.push(Lesson {
                project,
                kind,
                slug,
                text,
            }),
            None => skipped += 1,
        }
    }
    (lessons, skipped)
}

fn tokens(s: &str) -> HashSet<String> {
    s.to_lowercase()
        .split(|c: char| !(c.is_ascii_alphanumeric() || c == '_' || c == '-'))
        .filter(|t| t.len() >= 4 && !STOP.contains(t))
        .map(str::to_owned)
        .collect()
}

/// Top `n` lessons: score = (3 if project matches + shared tokens) * kind weight,
/// shared >= 1 required.
pub(crate) fn rank<'a>(
    lessons: &'a [Lesson],
    project: &str,
    query: &str,
    n: usize,
) -> Vec<&'a Lesson> {
    let q = tokens(query);
    let mut scored: Vec<(usize, &Lesson)> = lessons
        .iter()
        .filter_map(|l| {
            let shared = tokens(&format!("{} {}", l.slug, l.text))
                .intersection(&q)
                .count();
            let bonus = if l.project.0.eq_ignore_ascii_case(project) {
                3
            } else {
                0
            };
            (shared >= 1).then_some(((bonus + shared) * l.kind.weight(), l))
        })
        .collect();
    scored.sort_by_key(|s| std::cmp::Reverse(s.0));
    scored.into_iter().take(n).map(|(_, l)| l).collect()
}

fn truncate_bytes(s: &str, max: usize) -> &str {
    let mut end = max.min(s.len());
    while !s.is_char_boundary(end) {
        end -= 1;
    }
    &s[..end]
}

pub(crate) fn render(top: &[&Lesson]) -> Option<String> {
    if top.is_empty() {
        return None;
    }
    let items: Vec<String> = top
        .iter()
        .map(|l| {
            let text: String = l.text.split_whitespace().collect::<Vec<_>>().join(" ");
            let text: String = text.chars().take(ITEM_CHARS).collect();
            format!("[{} {}] {}", l.kind.as_str(), l.label(), text)
        })
        .collect();
    let full = format!("{HEADER}{}", items.join("\n"));
    Some(truncate_bytes(&full, CAP).to_owned())
}

fn walk_project(cwd: &Path) -> Option<String> {
    cwd.ancestors()
        .find(|d| d.join(".jj").is_dir())
        .or(Some(cwd))
        .and_then(|d| d.file_name())
        .map(|n| n.to_string_lossy().into_owned())
}

/// Hook output for one stdin payload; None = stay silent (fail-open).
pub(crate) fn hook_output(input: &[u8], lessons: &[Lesson]) -> Option<String> {
    let v: Value = serde_json::from_slice(input).ok()?;
    let event = v.get("hook_event_name")?.as_str()?;
    let field = |k: &str| v.get(k).and_then(Value::as_str).unwrap_or("");
    let query = match event {
        "UserPromptSubmit" => field("prompt").to_owned(),
        "SubagentStart" => format!(
            "{} {} {}",
            field("agent_type"),
            field("prompt"),
            field("description")
        ),
        _ => return None,
    };
    let project = walk_project(Path::new(field("cwd"))).unwrap_or_default();
    let ctx = render(&rank(lessons, &project, &query, 3))?;
    Some(
        json!({"hookSpecificOutput": {"hookEventName": event, "additionalContext": ctx}})
            .to_string(),
    )
}

fn cache_path() -> Option<PathBuf> {
    Some(PathBuf::from(std::env::var_os("HOME")?).join(".cache/vic/recall.json"))
}

fn to_json(lessons: &[Lesson]) -> String {
    Value::Array(
        lessons
            .iter()
            .map(|l| json!({"project": l.project.0, "kind": l.kind.as_str(), "slug": l.slug, "text": l.text}))
            .collect(),
    )
    .to_string()
}

fn from_json(s: &str) -> Option<Vec<Lesson>> {
    let v: Value = serde_json::from_str(s).ok()?;
    v.as_array()?
        .iter()
        .map(|o| {
            let g = |k: &str| o.get(k).and_then(Value::as_str);
            Some(Lesson {
                project: Project::new(g("project")?)?,
                kind: Kind::parse(g("kind")?),
                slug: g("slug")?.to_owned(),
                text: g("text")?.to_owned(),
            })
        })
        .collect()
}

/// `vic hook recall`: always exit 0.
pub(crate) fn run_hook() -> i32 {
    let mut raw = Vec::new();
    if std::io::stdin().read_to_end(&mut raw).is_err() {
        return 0;
    }
    let Some(lessons) = cache_path()
        .and_then(|p| fs::read_to_string(p).ok())
        .and_then(|s| from_json(&s))
    else {
        return 0;
    };
    if let Some(out) = hook_output(&raw, &lessons) {
        println!("{out}");
    }
    0
}

/// `vic recall build`: prints `recall: N lessons, M skipped`.
pub(crate) fn build(db: Option<PathBuf>) -> Result<(), VicError> {
    let cache = cache_path().ok_or_else(|| VicError::Recall("HOME unset".to_owned()))?;
    let db = db
        .or_else(|| {
            std::env::var_os("HOME").map(|h| PathBuf::from(h).join(".local/share/quipu/quipu.db"))
        })
        .ok_or_else(|| VicError::Recall("HOME unset".to_owned()))?;
    let out = Command::new("quipu")
        .arg("read")
        .arg(SPARQL)
        .arg("--db")
        .arg(&db)
        .stdin(Stdio::null())
        .stderr(Stdio::null())
        .output()?;
    if !out.status.success() {
        return Err(VicError::Recall(format!(
            "quipu read exited {}",
            out.status
        )));
    }
    let (lessons, skipped) = parse_tsv(&String::from_utf8_lossy(&out.stdout));
    let dir = cache
        .parent()
        .ok_or_else(|| VicError::Recall("bad cache path".to_owned()))?;
    fs::create_dir_all(dir)?;
    let tmp = dir.join(format!("recall.json.tmp{}", std::process::id()));
    fs::write(&tmp, to_json(&lessons))?;
    fs::rename(&tmp, &cache)?;
    println!("recall: {} lessons, {skipped} skipped", lessons.len());
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn l(kind: Kind, proj: &str, slug: &str, text: &str) -> Lesson {
        Lesson {
            project: Project(proj.to_owned()),
            kind,
            slug: slug.to_owned(),
            text: text.to_owned(),
        }
    }

    #[test]
    fn label_good_bad_other() {
        assert_eq!(
            parse_label("ledger:vix/mistake/a/b"),
            Some((Project("vix".into()), Kind::Mistake, "a/b".into()))
        );
        assert_eq!(
            parse_label("ledger:vix/weird/x").map(|t| t.1),
            Some(Kind::Other("weird".into()))
        );
        assert_eq!(parse_label("ledger:vix/mistake"), None);
        assert_eq!(parse_label("ledger:/mistake/x"), None);
        assert_eq!(parse_label("other:vix/mistake/x"), None);
    }

    #[test]
    fn tsv_measured_escapes() {
        let tsv = "l\tc\n----\n\"ledger:a/mistake/one\"\t\"has \"raw quotes\" and \\n literal\nsecond line\"\n\"ledger:a/bad\"\t\"x\"\n\"ledger:b/evidence/two\"\t\"plain\"\n\n3 results\n";
        let (ls, skipped) = parse_tsv(tsv);
        assert_eq!(skipped, 1);
        assert_eq!(ls.len(), 2);
        assert_eq!(
            ls[0].text,
            "has \"raw quotes\" and \\n literal\nsecond line"
        );
        assert_eq!(ls[1].text, "plain");
    }

    #[test]
    fn tsv_garbage_is_empty() {
        assert_eq!(parse_tsv("garbage"), (vec![], 0));
        assert_eq!(parse_tsv(""), (vec![], 0));
    }

    #[test]
    fn mistake_beats_evidence_and_project_bonus() {
        let ls = vec![
            l(Kind::Evidence, "vix", "e", "alpha bravo"),
            l(Kind::Mistake, "vix", "m", "alpha bravo"),
            l(Kind::Evidence, "other", "o", "alpha bravo charlie"),
        ];
        let top = rank(&ls, "vix", "alpha bravo", 3);
        assert_eq!(top[0].slug, "m");
        assert_eq!(top[1].slug, "e");
        let top = rank(&ls, "zzzz", "charlie", 3);
        assert_eq!(top[0].slug, "o");
        let ls = vec![
            l(Kind::Evidence, "a", "x", "alpha"),
            l(Kind::Evidence, "vix", "y", "alpha"),
        ];
        assert_eq!(rank(&ls, "vix", "alpha", 3)[0].slug, "y");
    }

    #[test]
    fn no_shared_token_no_match() {
        let ls = vec![l(Kind::Mistake, "vix", "m", "alpha bravo")];
        assert!(rank(&ls, "vix", "nothing here", 3).is_empty());
        assert!(rank(&ls, "vix", "the and", 3).is_empty());
    }

    #[test]
    fn cap_600_bytes() {
        let long = "alpha ".repeat(200);
        let ls: Vec<Lesson> = (0..5)
            .map(|i| l(Kind::Mistake, "vix", &format!("s{i}"), &long))
            .collect();
        let ctx = render(&rank(&ls, "vix", "alpha", 3)).unwrap_or_default();
        assert!(ctx.len() <= CAP && ctx.starts_with(HEADER), "{}", ctx.len());
        let multi = vec![l(Kind::Mistake, "vix", "m", &"é".repeat(400))];
        assert!(render(&rank(&multi, "vix", &"é".repeat(5), 3)).is_none());
    }

    #[test]
    fn fail_open_on_garbage() {
        let ls = vec![l(Kind::Mistake, "vix", "m", "alpha bravo")];
        assert_eq!(hook_output(b"not json", &ls), None);
        assert_eq!(hook_output(b"{}", &ls), None);
        assert_eq!(hook_output(br#"{"hook_event_name":"Stop"}"#, &ls), None);
        assert_eq!(
            hook_output(br#"{"hook_event_name":"UserPromptSubmit","prompt":7}"#, &ls),
            None
        );
    }

    #[test]
    fn hook_emits_event_and_roundtrips() {
        let ls = vec![l(Kind::Mistake, "vix", "m", "alpha bravo")];
        let ls = from_json(&to_json(&ls)).unwrap_or_default();
        let out = hook_output(
            br#"{"hook_event_name":"SubagentStart","cwd":"/x/vix","agent_type":"alpha"}"#,
            &ls,
        )
        .unwrap_or_default();
        let v: Value = serde_json::from_str(&out).unwrap_or(Value::Null);
        assert_eq!(v["hookSpecificOutput"]["hookEventName"], "SubagentStart");
        assert!(v["hookSpecificOutput"]["additionalContext"]
            .as_str()
            .is_some_and(|c| c.contains("[mistake ledger:vix/mistake/m]")));
    }
}
