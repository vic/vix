# Vic Forcing Functions, Experiment Gate & Anti-Rationalization Card

Compact operational reference for `/vic`. When in doubt, run `scripts/vic-preflight.sh` first.

## 1. The 5 Non-Negotiable Experiment-Based Development Gates

1. **Purpose before Elements (`/pie`):** 1–2 line consumer goal + measurable exit state + explicit NOT-PURPOSE before naming any file, module, or agent.
2. **Evidence before Code (`/probes` + `evidence-gate.sh`):**
   - Measure TODAY's `main` baseline on the whole workload.
   - Isolate locus (`MINREPRO` -> `FLIP TABLE` -> `COUNTERS`).
   - Size the lever with a throwaway 30-min ablation stub (`verdict: STUB`).
   - Revert stub byte-identical; record `verdict: PASS` (or `FAIL` -> kill idea, write zero code).
3. **Oracle + Negative Control before Impl (`/oracle`):**
   - Write failing test (RED) before code; prefer two independent paths agreeing.
   - Arm every check with a compiling product-site mutant (or compile-fail `-Wswitch` mutant for exhaustive switches).
   - Prove clean restore via `sha256sum` before landing.
4. **Least Code, Type-Enforced (`Δ+lines < Δ-lines`):**
   - Make illegal states unrepresentable (closed enums, typed outcomes, validated entry wrappers, zero sentinels, zero `default:`).
   - Fix invariants at the producer (write site), never read-site band-aids.
   - Prune dead code proved by surviving mutants.
5. **Time & Retry Caps (Zero Hour-Long Deviations):**
   - Single command `timeout 60..120`, isolated unit test `< 1 s`, worker agent `<= 5–10 min`.
   - Same approach fails TWICE -> 3rd try MUST escalate tier or redesign from fresh measurement.
   - 3 total fails -> HARD STOP + `/escalate` artifact.

## 2. Anti-Rationalization Trap Table

| Thought | Truth | Mandatory Action |
|---|---|---|
| *"Quick fix now, clean later"* | Creates N downstream bugs | Fix invariant at producer in types NOW |
| *"Just one more try"* (after 2 fails) | Sunk-cost thrash | Stop -> probe/measure -> escalate tier or redesign |
| *"The test is probably wrong"* | Blind expectation edit | Independently derive spec truth -> ruling -> then edit |
| *"Numbers look fast enough"* | Unmeasured guess | Run deterministic instruction + RSS gate vs. same-host main tip |
| *"Skip the stub, I see the bottleneck"* | 3x blind perf rework failure | Run 30-min `STUB` ablation on release inlined build first |
| *"Task is small, skip workspace/oracle"* | Contaminates main / ships unarmed check | Isolate in `jj` workspace; write RED + mutant |
| *"Agent reported green, ship it"* | Agents hallucinate & leave live mutants | Verify diff, SHA restore, and verbatim outputs on disk |
