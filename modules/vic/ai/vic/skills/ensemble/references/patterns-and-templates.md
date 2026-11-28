# Ensemble Copy-Paste Templates

## Pattern 1: K-Shot Worker + Independent Judge
**Pre-flight (mandatory):** Confirm oracle FAILS RED on clean base commit before spawning `k` attempts.

**Worker (`haiku/low`, `<= 2K` tokens, `<= 5 min`):**
```text
ATTEMPT k=<k> | WORKSPACE: <abs-ws-path> (ZERO jj/git commands)
GOAL: <1 line>
FILES (EXACT): <1-2 files>
ORACLE: <exact command + expected PASS line>
HINT: <k=0: direct clean implementation; k=1: alternative data layout; k=2: minimal iterative form>
REPORT (<= 10 lines): files edited, exact oracle output, EXIT=$?.
```

**Judge (`vic-judge`, `haiku/low`, `<= 5 min`):**
```text
Read-only judge. Do NOT edit files.
Run exact oracle + mutant check on workspaces: <ws0> <ws1> <ws2>.
Verify binary rebuilt inside each ws (not stale). Pick FIRST passer that also kills the mutant.
Return: WINNER=<ws | NONE>, per-ws PASS/FAIL + exact evidence lines.
```

## Pattern 2: 3-Way Consensus Triage
Spawn 3 identical `haiku/low` classifiers with zero shared context -> `vic-judge` emits `UNANIMOUS` items vs. `SPLIT` items (route only `SPLIT` to `sonnet/med` with the 3 answers attached).

## Pattern 3: Compiled Checklist Unit
```text
STEP 1: <exact single edit/action>
  CHECK: <exact command > /tmp/s1.out 2>&1; echo EXIT=$?>
  EXPECT: <exact line / count>
  ON-FAIL: STOP and report step 1 verbatim.
```
