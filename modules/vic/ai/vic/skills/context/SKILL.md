---
name: context
description: Context-economy law (ALL projects) — thin-supervisor discipline, unified context thresholds (60/70/80/90%), pollution/drift prevention, 4-read fresh bootstrap, and hard byte-budget gates. Use at session start, before any big read/run, and whenever drift is suspected.
---

# CONTEXT ECONOMY LAW (vic, global)

**Core law:** *The model that THINKS never SCROLLS.* Strong models burn 4–8x more per token than fast workers; delegating noisy reads/builds/logs to cheap workers keeps the reasoning context razor-sharp.

**Stack:** `/vic-stack` — `quipu` label-prefix recall (~65 ms) and `ircc` peer asks replace bulk re-reading and re-derivation.

**Assets in this skill:**
- `references/bootstrap-checklist.md` — exact 4-read cold bootstrap manifest (`<= 4K` tokens) and doc-compression byte-budget rule.
- `scripts/ctx-check.sh` — reads real assistant token usage from a session transcript JSONL (matching `pre-compact.sh`) + checks `HANDOFF.md` freshness and size.

---

## 1. Thin Supervisor Law

Keep the main/lead context strictly for **deriving invariants, reviewing concise diffs, deciding rulings, and dispatching**:
- Bulk file reads `> 1 screen` -> `vic-reader` (`haiku/low`)
- Builds, test suites, benchmarks, probes -> `vic-probe` / `LAND-VERIFY` / `PROBE` (`haiku/low`)
- Corpus sweeps / censuses -> `vic-sweep` (`haiku/low`)
- Symbol / caller / impact lookup -> `codegraph_*` MCP tools (never raw `grep` first)
- Diff review -> `vic-reviewer` (`sonnet/med`)
- Doc / handoff / ledger upkeep -> `vic-scribe` (`haiku/low`)

Workers pollute their own disposable contexts and die; only their distilled `<= 25`-line verified report enters yours.

---

## 2. Unified Context Thresholds (reconciled with global hooks)

| Context % | Hook / Protocol | Required Action |
|---|---|---|
| `>= 60%` | Rule pulse | Offload all reads/runs/hygiene; keep working copy clean |
| `>= 70%` | `stop-gate.sh` | Update `vic/HANDOFF.md` (`<= 25` lines) + `state.md`; prefer clean restart from `HANDOFF.md` over compaction |
| `>= 80%` | Paired-session wind-down | Finish active verification step, land clean tip, write full handover |
| `>= 90%` | `pre-compact.sh` | Auto-compaction unblocks only as last-resort backstop |

*Owner override:* Never abort an in-flight critical step solely for a noisy hook alarm — finish cleanly on a verified tip and follow owner wind-down instructions.

---

## 3. Drift Detection & Recovery

**Symptoms:** re-reading your own output · *"one more fix"* loops · archaeology on your own failed attempts · skipping citations or negative controls.
**Fix:** STOP immediately. Remember **code is disposable** — a 1-minute rewrite from a clean spec beats an hour debugging tangled attempts. Update `HANDOFF.md` and restart fresh.

---

## 4. Fresh Bootstrap = Exactly 4 Reads (`<= 4K` tokens)

1. `<proj>/vic/HANDOFF.md` (`<= 25` lines)
2. Project skill / workflow law (roles, gates, commands)
3. The ONE active spec/task brief (or newest 20–40 lines of `state.md`)
4. Matching playbook in `<proj>/vic/playbooks/` (if any)

Never cold-read full history ledgers or all specs *"for context"*. When compressing docs with an agent, set a **hard byte/line budget** in the spec and verify size as a pass/fail gate (compression agents hedge to 90–100% otherwise).
