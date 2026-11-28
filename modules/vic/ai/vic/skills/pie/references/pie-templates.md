# PIE Templates (Design Spec, Fleet Decomposition, Restructure Move)

## 1. PIE Design Spec Skeleton

```markdown
# <Title>

## P — Purpose
- **Consumer need:** <1-2 lines: who needs what capability NOW>
- **Measurable exit state:** <exact verifiable condition proving success>
- **Non-goals (explicit NOT-PURPOSE):** <what we refuse to build>

## I — Interactions (Contracts, Protocol, Oracle)
- **Inputs & Outputs (typed, illegal states unrepresentable):**
  - Input: `<ExactType>`
  - Output: `<ClosedOutcomeEnum + Payload>` (zero sentinels)
- **Protocol:** <caller -> callee sequence, ownership, error propagation, seq vs parallel>
- **Oracle & Negative Control:**
  - Positive oracle: <exact command / differential check>
  - Armed negative control / mutant: <what fails when broken>
- **Experiment / Perf Bar (stated before building):**
  - Ablation / baseline: <measured numbers + setup>
  - Gate: <= +1% instructions, <= +2% RSS (or stated lever bar)

## E — Elements (Minimal Implementation Units)
- **Element 1 (`<module/file/agent>`):** single responsibility; owned files; complexity bound.
- **Deleted / Simplified:** <what existing code or workaround this removes>
```

## 2. PIE Fleet / Parallel-Lane Decomposition

```markdown
## P — Wave Purpose
<Critical-path milestone closed by this wave>

## I — Lane Boundaries & Handoffs
| Lane | Owned Files (src + tests, strictly disjoint) | Input Artifact | Output / Oracle | Lands After |
|---|---|---|---|---|
| L1 | `...` | `main tip` | `unit + mutant + perf` | independent |
| L2 | `...` | `main tip` | `unit + mutant + perf` | independent |

## E — Assigned Elements
- Design lead: hardens briefs, reviews diffs, lands linearly
- Workers: `haiku/low` (mechanical/probes/perf), `sonnet/med` (spec'd code), `opus/high` (hard invariants)
- Auditor: `[verify-commit]` -> `[verify-result]` asynchronously on each landed commit
```

## 3. PIE Restructure Move Receipt

```markdown
## Restructure: <Overloaded Element>
- **Measured symptom:** <e.g., task exceeded 10-min cap twice / ctx > 70% / 3 files coupled>
- **Frozen Interaction (I):** <unchanged consumer signature + oracle command proving parity>
- **Split Elements (E):**
  1. `<Element A>`: <cohesive job 1>
  2. `<Element B>`: <cohesive job 2>
- **Rewiring:** <sequential -> parallel fan-out + single combine>
- **Verification:** consumer oracle green with zero caller changes.
```
