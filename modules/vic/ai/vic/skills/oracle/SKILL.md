---
name: oracle
description: Oracle-first discipline (ALL projects). Use BEFORE writing any spec, implementation, or fix, and whenever validating a "green"/"passing"/"it works" claim or distrusting a suite. Triggers — acceptance test, "how will we know it's fixed", verify an agent's result, suspicious pass, flaky suite. Do NOT use for running tests you've already designed, or for unrelated debugging (use systematic-debugging / probes). A weak or cheatable oracle is worse than none — load the skill for the oracle shapes, mandatory negative controls, and the traps that burned us before designing it.
---

# ORACLE LAW (vic, global) CVMN — receipts: 8× first-run-green in one session w/ this; every trap below burned us once.

## SHAPES (strongest first)
1. TWO INDEPENDENT PATHS AGREE (neither can cheat the other) — strongest.
2. EXACT-OUTPUT vs hand-derived value (hand-built indices/offsets: derive table in comment FIRST — 3 bugs from skipping).
3. COUNTER SIGNATURE: exact counts w/ known law (e.g. linear invariant). Counter must be ≫1 — counter:1 = measuring NOTHING.
4. EXIT-CODE GATE: weakest alone; combine w/ 1-3 on samples.

## NEGATIVE CONTROLS — MANDATORY
Every checker/encoder/prover test ships ≥1 REJECTED mutant (2+2≢3, arity-mutant, false-equation, tampered input). Green-only = "suite-green ≠ rule-fired" trap (rule NEVER fired, suite green anyway — receipt). Rule-level claims: per-class counters asserted ≫0.

## TRAPS (each cost a session-chunk)
- SHARING-BLIND tests: simple outputs hide sharing/dedup bugs — drive shared-structure code through compounding inputs (numeral-application class catches what trivial terms miss).
- TESTS ASSERTING THE BUG: good fix breaks them. On break: verify new value SOUND first (law argument), THEN update test w/ justification — not success-theater.
- UNREADABLE RESULT: when direct check hard, state the soundness argument explicitly (each step licensed + confluence/uniqueness ⟹ result correct). No hand-wave.
- AGENTS CHEAT TESTS: "N tests pass" MEANS NOTHING. Demand RED→GREEN→mutant-REJECTS pastes; spot-check diff didn't weaken oracle.
- UNGUARDED SUBPROCESS in tests = harness hang. Kill-timer always.
- Timing/float assertions = flake; forbidden in oracles.

## LAW
No impl dispatched w/o oracle written + RED confirmed. No "validated" accepted w/o oracle named + outputs pasted. Fix w/o red test = reverted.
