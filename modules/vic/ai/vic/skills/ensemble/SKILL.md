---
name: ensemble
description: Haiku-amplification law (ALL projects) — make fast/cheap models beat expensive ones via k-shot + armed mechanical oracle filter, consensus triage, and checklist compilation. Use whenever tempted to dispatch sonnet/opus on work whose OUTPUT IS MECHANICALLY CHECKABLE.
---

# ENSEMBLE LAW (vic, global) — k × haiku + armed oracle >> 1 genius when verification << generation

**Stack:** `/vic-stack` — recall `quipu` evidence before a k-shot fan-out; record winning oracle patterns and ROI telemetry. Pair with `/oracle` (armed negative controls), `/workspace` (isolated `jj` workspaces per attempt), and `/superhaiku` (full DAG pipeline).

**Assets in this skill:**
- `references/patterns-and-templates.md` — copy-paste prompts for Pattern 1 (k-shot + armed oracle), Pattern 2 (3-way consensus triage), and Pattern 3 (checklist compilation).
- `scripts/ensemble-roi.sh` — compares empirical cost-per-accepted-unit of an ensemble run vs. a solo higher-tier run (`5×haiku ≈ 0.6×sonnet ≈ 0.15×opus`) to prove ROI or trigger reversion.

---

## 1. The Honest Physics (route strictly by this)

- **Ensemble works ONLY when wrongness is mechanically catchable cheap** (tests, compilers, schema validators, exact diffs, parsers, formatters).
- **NEVER ensemble:** soundness proofs, root-cause verdicts, novel design choices, or spec/law interpretation (verification ≈ generation -> use `opus/high` or `xhigh` directly).
- **Cost math:** `5 × haiku ≈ 0.6 × sonnet ≈ 0.15 × opus ≈ 0.08 × xhigh`. Beats solo sonnet whenever `>= 1` of `k` passes an armed oracle reliably.

---

## 2. Three Proven Patterns

1. **K-Shot + Armed Oracle Filter (generation):**
   - **Pre-condition:** Run the oracle on the baseline FIRST and prove it FAILS RED (an unarmed oracle makes attempt 0 falsely win!).
   - Spawn `k = 3..5` `haiku/low` attempts in parallel (separate `jj` workspaces for code edits, `description: "haiku/low: k<n> <task>"`, prompt `<= 2K` tokens, vary approach hint by `k`).
   - An independent `vic-judge` (`haiku/low`) runs the oracle + negative control on each workspace -> first verified passer wins; supervisor lands winner linearly and abandons losers.
2. **3-Way Consensus Triage (classification / census):**
   - Spawn 3 independent `haiku/low` workers (zero shared context).
   - `vic-judge` diffs outputs: **3/3 unanimous + spot-checked** -> accept; **split** -> escalate ONLY the contested item one tier with the disagreement attached (disagreement = free uncertainty signal).
3. **Checklist Compilation (multi-step chains):**
   - Cheap models fail long chains but nail atomic steps. Compile the chain ONCE (`sonnet/med` planner or lead): numbered micro-steps, each with exact `CMD`, `CHECK`, `EXPECT`, and `ON-FAIL: STOP`. Execute strictly via `vic-chain` (`haiku/low`).

---

## 3. Hard Stop Valves

- **Keep haiku prompts `<= 2K` tokens** (reference checklist/playbook files; big inline walls cause drift).
- **Oracle runs OUTSIDE the generator** (`vic-judge` or harness — self-graded haiku is theater).
- **2-round stop cap:** If 2 ensemble rounds fail the oracle -> STOP, escalate ONE tier with all failures attached (never burn round 3 at haiku).
- **Prove ROI:** Check `scripts/ensemble-roi.sh` via `vic-telemetry`; if ensemble cost per accepted unit exceeds solo tier, revert routing for that class.
