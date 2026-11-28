# Superhaiku Unit Spec Schema & Dispatch Pattern

## 1. Compiled Unit Spec (`<= 2K` tokens, `<= 2` files, `<= 5 min`)

```text
UNIT <uN> | TICKET: <bead-id> | CAP: <= 5 min
WORKSPACE: <abs-ws-path>  (ZERO jj/git commands; foreground builds only)
P (GOAL): <1 line>
FILES (EXACT, <= 2): <file1> [<file2>]
STEPS:
  1. <exact atomic edit anchored by exact text>
  2. Build inside WORKSPACE (`cd <ws> || exit 1; timeout 90 <build> > /tmp/uN.log 2>&1; echo EXIT=$?`).
  3. Run unit oracle (`timeout 30 <oracle> > /tmp/uN.test 2>&1; echo EXIT=$?`).
ORACLE: <exact expected output>
NEGATIVE CONTROL: <mutant or bad input that MUST fail>
ATTEMPT <k>: <k=0: direct minimal impl; k=1: alternate layout; k=2: simple explicit loop>
REPORT (<= 10 lines): files, build warnings, oracle output, EXIT codes.
```

## 2. Standard Agent Tool Fan-Out (compliant with `agent-tier-gate.sh`)

For each ready DAG node `uN`:
1. Confirm baseline RED via `scripts/ws-fanout.sh create --repo . --unit uN --k 3 --red-cmd "<oracle>"`.
2. In ONE parallel turn, invoke `k` Agent calls:
   - `subagent_type: "vic-superhaiku"`, `model: "haiku"`, `description: "haiku/low: uN a<k> <short-title>"`
3. Invoke ONE `vic-judge` (`model: "haiku"`, `description: "haiku/low: judge uN"`) receiving all `k` workspace paths + the exact oracle + negative control command.
4. Supervisor lands winner linearly (`jj-land-linear.sh`), abandons losers, and runs `scripts/ws-fanout.sh cleanup`.
