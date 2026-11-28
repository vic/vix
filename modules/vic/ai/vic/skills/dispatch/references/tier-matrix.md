# Dispatch Tier Matrix & Spec Skeleton

## 1. Cost Ratios & Mis-Pairing Receipts

Relative burn: `xhigh ≈ 2× opus ≈ 4× sonnet ≈ 8× haiku`.
- `haiku/xhigh` -> drift loops (wrong pairing)
- `xhigh/low` -> paying genius to copy-paste (waste)
- `opus` without `< 1 s` `MINREPRO` -> 10× burn
- `sonnet` on underspecified brief -> plausible-wrong code reverted

## 2. Mandatory PIE Spec Skeleton (every coding dispatch)

```text
TASK <ID>: <title>  |  TICKET: <plain-id>  |  CAP: <= 10 min
P (GOAL): <1-2 lines consumer purpose + how it moves critical path>
NOT-SCOPE: <explicit exclusions — zero bonus refactors or speculative layers>
WORKSPACE: <abs jj ws path> (ZERO jj/git commands; foreground builds only)
INLINE LAWS: closed enums, typed outcomes, zero sentinels/default:/abort/todo, 0 warnings across compilers+san,
             full-word names, timeout <= 120s, capture > file; echo EXIT=$? (never after pipe), Edit tool only.
FILES (exact): <list>
I (CONTRACT & ORACLE):
  - Exact types/signatures/names ruled
  - RED check first -> GREEN exact count
  - Product-site compilable mutant(s) + clean-restore SHA-256 proof
  - Pre-debunked dead leads: <what NOT to try>
  - Honesty clause: report verbatim even if slower/negative
E (EXECUTION): model=<tier>, effort=<effort>, max 2 failed attempts before STOP + report
REPORT (<= 25 lines): files, RED, GREEN, mutant FAIL + restore SHA, perf gate line, drifts.
```
