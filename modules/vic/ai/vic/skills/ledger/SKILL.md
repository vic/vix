---
name: ledger
description: Knowledge-preservation law (ALL projects) — command ledger (recall before re-run), past-generation transcript mining, telemetry duty on every dispatch, archival. Use before ANY expensive command, before solving anything previously-solved-smelling, at every handoff.
---

# LEDGER LAW (vic, global) CVMN — knowledge is constructed; re-running/re-thinking the known = #2 burn after fat context.

## COMMAND LEDGER (automatic — global cmd-ledger hook logs EVERY Bash cmd + FULL output)
~/.cache/claude-ledger/<project-key>/bash-YYYYMMDD.jsonl (ts+sid+cmd+out60K+err). Outside repos ⟹ no VCS churn.
- **RECALL-BEFORE-RUN**: b4 any expensive cmd (build/lint/suite/bench): `vic-recall '<pattern>'`. Tree unchanged since entry ⟹ that output IS current; re-running = pure waste.
- **KILLS TAIL TRAP**: tail/truncate in-context (correct), full output in ledger — missed detail ⟹ vic-recall, NEVER re-run for a bigger tail.

## GENERATION MINING
`vic-mine '<pattern>'` — searches THIS project's past session transcripts (prior generations ran it / solved it / killed it). Snippets + generation files; deep-dive = vic-reader on the .jsonl, NEVER inline (huge). Ranking: curated project docs (track DEAD/state) FIRST; mine for what curation missed. Periodic distill (vic-scribe): notable threads → tracks/playbooks; `notebooklm-pack` for archival to 2nd brain (direction only, never soundness).

## TELEMETRY DUTY
After EVERY Agent/Workflow: `vic-telemetry add <agent> <model> <tier> <secs> <tokens> <outcome> [note]` (usage in tool results). state.md blocks + HANDOFF carry `BURN:` line. `vic-telemetry report` = routing feedback: tok/run high + ok on easy class ⟹ downgrade tier in /dispatch; fails high ⟹ tighten spec FIRST (spec cheaper than tier). /dispatch table = LIVING policy; scribe edits w/ receipt.

## BURN RATIOS (route by this)
fable ≈2× opus ≈4× sonnet ≈8× haiku. haiku 4.5 · sonnet 4.6 · opus 4.8 · fable 5 (retires ~2026-06-17).
