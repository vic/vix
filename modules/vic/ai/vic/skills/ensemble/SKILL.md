---
name: ensemble
description: Haiku-amplification law (ALL projects) — make cheap models competitive with expensive ones via k-attempts + mechanical filter, consensus triage, checklist compilation. Use whenever tempted to dispatch sonnet/opus on a task whose OUTPUT IS MECHANICALLY CHECKABLE.
---

# ENSEMBLE LAW (vic, global) CVMN — k haiku + oracle ≫ 1 genius, WHEN verification ≪ generation.

## THE PHYSICS (honest — route by this, no wishful thinking)
Haiku matches fable on EXECUTION when wrongness is CATCHABLE cheap. Haiku NEVER matches on: derivation, novel design, multi-constraint tradeoffs, knowing-the-question-is-wrong. Test: "can a dumb check reject a wrong answer?" YES → ensemble-able. NO (verify ≈ generate, proof-grade) → opus/fable, no ensemble saves you.
COST MATH: 5×haiku ≈ 0.6×sonnet ≈ 0.15×opus ≈ 0.08×fable. Ensemble of 5 w/ filter beats sonnet WHEN ≥1-of-5 passes oracle reliably.

## PATTERN 1 — K-SHOT + ORACLE FILTER (generation tasks)
k=3-5 vic-chain/vic-probe attempts IN PARALLEL (same spec, vary only attempt-index) → vic-judge runs the ORACLE on each → first passer wins, rest discarded. Requires: runnable oracle (test/diff/schema/parse). Use Workflow tool for the fan-out+judge. Fixture gen, mechanical refactors, format conversions, shim impls, doc moves = prime targets.

## PATTERN 2 — CONSENSUS TRIAGE (judgment-lite tasks)
3 haiku INDEPENDENT answers (no shared context) → vic-judge diffs: UNANIMOUS+checkable → accept · SPLIT → escalate THAT item one tier w/ the disagreement attached (disagreement = free uncertainty signal). Classification, census labeling, error-class sorting = targets. Cuts opus triage to only the contested tail.

## PATTERN 3 — CHECKLIST COMPILATION (chain tasks — haiku's weakness killed)
Haiku fails long chains, nails single steps. COMPILE the chain once (sonnet vic-planner CHECKLIST MODE or supervisor): numbered micro-steps, EACH w/ its own CHECK command + expected output + ON-FAIL: STOP. Then vic-chain (haiku) executes strictly. Compilation cost paid once; execution = haiku forever (playbooks = pre-compiled checklists for recurring classes).

## RULES
- Haiku prompts SMALL (≤2K tokens): big context = haiku drift. Spec by reference to checklist/playbook file, not inline walls.
- Oracle runs OUTSIDE the generator (vic-judge / harness) — self-graded haiku = theater.
- 2 ensemble rounds fail oracle → STOP, tier up w/ failures attached (spec problem or genuine hardness — don't burn round 3).
- Telemetry both paths (vic-telemetry) — ensemble must PROVE cheaper per accepted unit or routing reverts.
- NEVER ensemble: soundness arguments, root-cause verdicts, design choices, law interpretation (wrongness not mechanically catchable).
