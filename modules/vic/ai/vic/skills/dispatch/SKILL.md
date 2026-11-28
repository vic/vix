---
name: dispatch
description: Model×effort dispatch law (ALL projects). Use BEFORE spawning ANY Agent/subagent or parallel fleet, and when sizing or tiering a task. Triggers — delegate, parallelize, fan-out, "which model", cheap-vs-expensive, agent burn, subagent spec, tier gate. Enforces agent-tier-gate.sh, 5m/10m caps, PIE-ordered specs, inline foundations, immutable <ID>-v2 re-staging, and workspace + oracle gates.
---

# DISPATCH LAW (vic, global) — tight specs buy cheap tiers; zero blind spawns

**Stack:** `/vic-stack` — every brief tells the agent to recall in `quipu` first and save verified results; for another project ask its session via `ircc` before dispatching recon.

**Assets in this skill:**
- `references/tier-matrix.md` — full model×effort matrix, time caps, mis-pairing receipts, PIE spec skeleton, and inline worker contract.
- `scripts/dispatch-lint.sh` — validates an agent spawn label/description (`agent-tier-gate.sh` compliance) AND verifies a dispatch brief has explicit `SCOPE`/`NOT-SCOPE`, oracle + negative control, `<= 10m` cap, inline laws (no external `Skill` call), and zero placeholders.

---

## 1. Label Law (hard-blocked by `agent-tier-gate.sh`)

Every Agent `description` and Workflow `label` MUST start with `<model>/<effort>:` — exact prefix from `haiku/low:` · `sonnet/med:` · `opus/high:` · `fable/xhigh:` — followed by a 3–5 word task title (e.g., `description: "sonnet/med: T12 parser enum"`).
- Always pass explicit `model` matching the prefix (never default-inherit the lead's opus/high).
- `vic-*` agents pin model+effort in frontmatter; untyped/general subagents MUST pass matching `model`.

---

## 2. Tier Selection & Unified Time Caps

| Tier | Agents | Use For | Max Conc | Hard Time Cap |
|---|---|---|---|---|
| `haiku/low` | `vic-probe/reader/sweep/scribe/chain/judge/superhaiku` | Instructions ARE the thinking: exact commands, probes, perf runs, `LAND-VERIFY`, extraction, docs | `<= 15` | `<= 5 min` |
| `sonnet/med` | `vic-rung/isolate/reviewer/planner` | Tight contract + objective oracle, LOCAL decisions only (default coding tier) | `3–4` | `<= 10 min` |
| `opus/high` | `vic-hunter/typesmith/lawyer/perf/retro/robin` | Multi-file invariants, hard root cause, persistent designer, escalation retry after 2 fails | `2–3` | `<= 10 min` |
| `xhigh` | `vic-derive` | Soundness-critical derivation / law-underspec ONLY | `1` | `<= 10 min` |

- **Partition BEFORE picking a tier:** 1 opus task usually splits into 1 design decision + 3 `haiku`/`sonnet` rungs. A tighter spec buys a cheaper tier; a frozen `/playbook` drops one tier; mechanically checkable tasks can downgrade via `/ensemble` (`k × haiku + judge`).
- **Anything > 10 min is TOO BIG:** Split into `-a`, `-b`, `-c` rungs BEFORE dispatching. Never spawn hour-long wandering agents.

---

## 3. Mandatory Pre-Dispatch Gates

1. **PIE order (`/pie`):** `P` (goal + why) -> `I` (exact types, output shape, oracle, report contract) -> `E` (tier) LAST.
2. **Evidence gate (`/probes`):** For optimizations/architectural bets on guarded files, confirm `evidence-gate.sh` ticket (`verdict: PASS` after ablation stub) before dispatching implementation.
3. **Workspace gate (`/workspace`, `/jj`):** Every repo-editing dispatch runs in its own isolated `jj` workspace on strictly disjoint files (source AND test-count files); worker runs ZERO `jj`/`git` commands.
4. **Oracle + negative control (`/oracle`):** RED check + compilable product-site mutant + clean-restore SHA required in every coding brief.
5. **Inline foundations:** Worker subagents often lack external `Skill` loaders. Inline core coding laws and point to the repo-local law file — NEVER write *"invoke Skill X"*.
6. **Immutable staged briefs:** Stage exact briefs `> 5 lines` with `sha256sum`; NEVER re-stage an already-dispatched brief in place (revisions go to `<ID>-v2` + new SHA).
7. **2-try approach cap / 3-total stop (`/escalate`):** Pre-debunk dead leads; cap retries at 2 on the same approach.

---

## 4. Post-Return Verification & Telemetry

- **Verify, never trust:** Agent reports are claims. Verify `diff --stat`, clean-restore SHA, and verbatim test outputs before landing; dead agents often leave salvageable green code on disk (inspect before re-dispatching).
- **Recall before re-run (`/ledger`):** Use `vic-recall` before repeating expensive runs; record `vic-telemetry add` + `gebed_report` (measured fields only) at task end.
