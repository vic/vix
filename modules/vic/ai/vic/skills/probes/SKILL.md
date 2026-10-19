---
name: probes
description: Measurement + isolation discipline (ALL projects) — probe-table-before-theory, ablation stubs, minrepro shrink law, freshness law. Use for any perf question, bug-hunt entry, "where does time/memory go", and before trusting any prior number.
---

# PROBE LAW (vic, global) CVMN

## ORDER (violating = the historical thrash pattern)
1. MINREPRO: shrink failing case smaller than goal, <1s (0.01s repro ≫ 83s). Same error-class preserved per shrink.
2. FLIP TABLE: one variable per row, verdict + key number. Equivalent PASS/FAIL twin pins the layer.
3. COUNTERS B4 THEORY: instrumented counts per variant. One counter kills weeks of wrong theory (receipts: stall-count → walk fix; scan-count → O(1) fix; size-count → whole layer acquitted).
4. ABLATION STUB = LOCUS PROOF: env-gated stub of suspect → measure delta → REVERT byte-identical (diff pasted). Order-of-magnitude delta = locus proven. No stub-proof ⟹ no optimization.
5. THEN theorize — and the 3rd "maybe" w/o new data = add a trace instead.

## FRESHNESS LAW (supreme — killed a wrong root-cause that survived 2 sessions)
NEVER build on a number whose probe setup you can't see/rerun (prior number was a scaffold artifact; fresh clean ablation killed the claim). Re-measure b4 extending any conclusion. Record setup (input file content or path) WITH every number. `vic-recall` = where past numbers + setups live.

## RUN HYGIENE
`vic-run <timeout> <cmd>` always (ulimit 8G + timeout + nice) · release builds for walls, profile stated · serial measurement · hang = "TIMEOUT >Ns" datapoint · probes env-gated default-off, KEEP · stubs/traces reverted b4 done · never consume all system memory — one big run at a time.

## SPLITS THAT MATTER
one-time vs marginal cost · construction vs execution count · startup vs compute wall · kernel-only vs e2e (kernel-only multiples = BANNED reporting class — e2e or nothing).
Project-specific probe catalogs (env vars, repro paths) live in the PROJECT skill (e.g. /dnx2).
