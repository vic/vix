# Experiment-Based Development Templates

## 1. Evidence Ticket (`<main>/vic/evidence/<workspace>.md` for `evidence-gate.sh`)

```yaml
measured: <main commit hash + date UTC>
locus: <file:line or symbol + profiler/counter numbers>
baseline: <whole-workload instr / rss / wall on clean main tip, setup recorded>
stub: <throwaway release-build ablation result on whole workload + byte-identical revert proof>
predicted: <expected delta + stated gate bar>
evidence: ledger:<proj>/evidence/<slug>
verdict: STUB   # STUB (<=30 min ablation window) | PASS (all fields filled) | FAIL (dead lever, stop)
```

## 2. Flip Table (Isolate 1 Variable per Row)

```markdown
| Case | Changed Variable | Expected | Measured | Verdict |
|---|---|---|---|---|
| base | none (clean tip) | FAIL | FAIL (0.04s, err=X) | baseline |
| f1 | disable optimization A | FAIL | PASS (0.04s) | **FLIP -> layer A** |
| f2 | shrink input N=100 -> N=8 | FAIL | FAIL (0.01s) | minrepro intact |
| f3 | single-threaded | FAIL | FAIL (0.01s) | not concurrency |
```

## 3. Step-by-Step Ablation Table (Separating Required Semantic Work from Overhead)

```markdown
| Variant | Instructions (`instructions:u`) | Delta vs Base | Peak RSS (KB) | Share of Delta |
|---|---|---|---|---|
| Base (clean tip) | `248,005,713` | `0.00%` | `39,852` | — |
| + New phase (tables disabled) | `248,303,320` | `+0.12%` | `39,900` | host overhead |
| + Required semantic tables | `253,100,000` | `+2.05%` | `40,120` | required rule work (94%) |
```
