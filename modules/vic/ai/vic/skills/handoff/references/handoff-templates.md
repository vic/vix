# Handoff & State Ledger Templates

## 1. `<proj>/vic/HANDOFF.md` (OVERWRITE, strictly <= 25 lines)

```markdown
# HANDOFF — <role> (<project>)
UPDATED: <YYYY-MM-DD HH:MMZ> · tip `<change> <commit>` · by `<role> [<sid>] (<model>/<effort>)`
DOING: <lane/task/bead/ws/brief-sha256 | idle — nothing in flight>
NEXT-CMD: `<verbatim runnable shell or dispatch command>`
THEN: 1. <next critical-path task + bead>  2. <following task + bead>
OPEN: <exact blockers, tries count "T1: try 1 failed X; try 2 failed Y", pending audits>
FILES: <uncommitted files in main copy | clean; active workspaces in lanes.md>
PERF-TIP: <label>=<instr>/<rss KB> @ `<tip-commit>`
BURN: <model>/<effort> ~<tok> <mins>m
RULES PULSE: <top 1-2 active session traps, e.g., check clean-restore SHA before land>
```

## 2. `<proj>/vic/state.md` Block (PREPEND, <= 15 lines)

```markdown
## <YYYY-MM-DD HH:MMZ> — <ID> <title> (`<change> <commit>`, bead `<id>`)
- **Result:** ACCEPTED | BLOCKED | FAILED (tries=<n>)
- **Evidence:** build=0warn (gcc/clang/san); tests=<N>/<N>; golden=<G>/<G>; mutants=<K>/<K> restored (`<sha>`)
- **Perf:** `<label>` instr `<cand>` vs `<base>` (`<delta>%`), rss `<cand>` vs `<base>` (`<delta>%`) -> PASS|FAIL
- **Rulings / Riders:** <Rnn added; P1/P2 riders queued>
- **Own slips:** <none | what happened -> concrete rule>
- **Next:** <next brief ID + staged sha256>
- **BURN:** <model>/<effort> <mins>m (code=<m>, perf=<m>, design=<m>)
```
