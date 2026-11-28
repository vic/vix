# Hands Lane Worker Brief Template (`<= 10 min`, absolute paths)

```text
LANE <lane> | TASK <ID> | TICKET <bead-id> | CAP <= 10 min (haiku/low <= 5 min)
WORKSPACE: <abs-ws-path>  (pinned commit: <sha>; pinned deps: <dep-sha>)

HARD RULES:
  - `cd <abs-ws-path> || exit 1` before every command; every file redirect uses ABSOLUTE paths.
  - ZERO jj or git commands; foreground builds one at a time; timeout 60..120 on every command.
  - Capture output to file, then `echo EXIT=$?` on the same line (never after a pipe).
  - Multi-line edits via Edit/Write tools only (never multi-line sed -i / perl -i).
  - Stop after 2 failed attempts or at time cap; report verbatim (never weaken tests or alter expectations).

FILES (EXACT): <list>
STEPS:
  1. Write RED check -> run -> paste failing lines.
  2. Apply exact minimal edit per contract -> build 0 warnings (all compilers + san).
  3. Run touched-file tests + oracle -> paste exact GREEN count.
  4. Save clean pre-mutant snapshots + SHA-256 -> run mutant(s) -> prove FAIL -> restore -> prove SHA match.

REPORT (<= 20 lines):
  LANE <lane> <ID> | bead <id> | commit-base <sha>
  RED / GREEN / MUTANT FAIL + RESTORE SHA / DRIFT (or none)
```
