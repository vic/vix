---
name: ledger
description: Knowledge-preservation & telemetry law (ALL projects) — recall-before-run command ledger, freshness validation against VCS state, past-generation transcript mining, accurate telemetry & gebed_report duty, and archival. Use before ANY expensive command, before re-solving something previously explored, and at every task end.
---

# LEDGER & TELEMETRY LAW (vic, global)

Re-running or re-deriving already-proven work is the #2 waste after fat context.

**Stack:** `/vic-stack` — `vic-recall` (Bash ledger), `vic-mine` (past transcripts), `quipu` label-prefix scans (verified facts), `gebed_report` (measured task metrics).

**Assets in this skill:**
- `references/ledger-recipes.md` — exact `vic-recall`, `vic-mine`, `vic-telemetry` (including the `a:outcome` `fail%` fix), and `gebed_report` stage-splitting recipes.
- `scripts/recall-fresh.sh` — verifies whether a cached `vic-recall` output is still fresh against the latest `jj op log` / working-copy modification time so stale ledger outputs are never blindly trusted.

---

## 1. Command Ledger (`vic-recall` — RECALL BEFORE RUN)

Global `vic hook ledger` automatically logs every Bash command and its full output (`<= 60 KB`) to `~/.cache/claude-ledger/<project-key>/bash-YYYYMMDD.jsonl` (outside repos -> zero VCS churn).
- **Before any expensive command** (build, full suite, benchmark): run `vic-recall '<pattern>'` AND check freshness with `scripts/recall-fresh.sh` (tree unchanged since entry -> output IS current; tree modified -> must re-run).
- **Kills the truncated-tail trap:** Keep in-context output short; when you need earlier lines from a completed run, fetch them via `vic-recall` — NEVER re-run a build/test solely for a longer tail.

---

## 2. Past-Generation Mining (`vic-mine`)

- `vic-mine '<pattern>'` searches prior session transcripts for this project (dead ends already killed, exact probes already run).
- Check curated docs (`HANDOFF.md`, `state.md`, `rulings.md`, `DEAD` sections) FIRST; mine transcripts for what curation missed.
- Delegate deep `.jsonl` inspection to `vic-reader` (`haiku/low`), NEVER inline.

---

## 3. Telemetry & Measured Reporting Duty

- **Tracker (`gebed_report` via `gebed-pm`):** At every task acceptance (or failure!), submit **one report per stage** (impl-agent, perf-agent, design) with ONLY that stage's minutes, measured fields only (omit unknown fields — never guess `0`). Only lane owners report `capacity: 1`.
- **Dispatch burn (`vic-telemetry`):** Record `vic-telemetry add <agent> <model> <tier> <secs> <tokens> <outcome> [note]` after dispatches.
  - *Known `vic-telemetry` bug:* Auto-hook `subagent` rows write `outcome=done` while `record()` counts `failed=0` only for `ok|accept`, inflating `fail%`. Compute true `fail%` directly from `a:outcome` in Quipu SPARQL (see `references/ledger-recipes.md`).
- **Routing feedback:** High tokens + 100% pass on an easy class -> freeze a `/playbook` and drop one model tier. High failure rate -> tighten the spec/oracle FIRST (tighter specs are cheaper than bigger models).
- **Relative burn ratios:** `xhigh/fable ≈ 2× opus ≈ 4× sonnet ≈ 8× haiku`.
