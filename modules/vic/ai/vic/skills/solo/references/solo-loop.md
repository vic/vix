# Solo 7-Step Experiment-to-Land Loop

1. **ORIENT (`<= 2 min`):** Recall `quipu` + `vic-recall` (check freshness); confirm goal gap and next critical-path rung.
2. **BASELINE:** Check host load (`scripts/solo-gate.sh --check-quiet`) and capture clean `main`-tip numbers with exact commit + dep SHAs.
3. **ABLATE (`verdict: STUB`, <= 30 min):** Prove the lever on a release build in a scratch copy/workspace. Revert stub byte-identical. Under bar -> log `DEAD` and pivot immediately.
4. **RED ORACLE:** Write minimal failing test (`< 1 s`) before editing production code.
5. **MINIMAL IMPL:** Fix the invariant at the producer site with the least code possible (closed enums, zero `default:`, zero sentinels, zero warnings across all compilers + sanitizers).
6. **MUTATE & GATE:** Run at least one compiling product-site mutant (`scripts/mutant-runner.sh`), prove FAIL + clean-restore SHA, run full gate + interleaved A/B perf (`scripts/ab-compare.sh`), verify `scripts/solo-gate.sh`.
7. **LAND & RECORD:** Linear `jj commit` on clean tip -> `gebed_report` (measured fields only) -> update `HANDOFF.md` + experiments log + `quipu`.

**Self-Stop Trigger:** If you hit 2 fails on the same approach OR > 30 min without a shrinking `MINREPRO`/new counter -> STOP, add a trace or write `/escalate`.
