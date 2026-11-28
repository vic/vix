# Lane Ledger Schema (`<proj>/vic/lanes.md`)

Update in the same turn as every workspace add, dispatch, rebase, land, or drop.

```markdown
# LANE LEDGER (<project>; max 5 disjoint lanes; linear landing only)

## Main Tip
- **MAIN TIP:** `<change> <commit>` — `<last landed task>` (verified: `<test counts>`, `<golden>`, `<perf>`)

## Active Lanes (max 5; files MUST be pairwise disjoint)
| lane | ws | base | ticket | files (src + tests) | state |
|---|---|---|---|---|---|
| core | `/run/user/1000/jj-ws/<repo>/core` | `<rev>` | `<id>` | `src/a.c, test/a-test.c` | IN_FLIGHT (code agent) |
| io | `/run/user/1000/jj-ws/<repo>/io` | `<rev>` | `<id>` | `src/b.c, test/b-test.c` | READY_TO_LAND |

## Serialized Queue (share hot wiring or count-assertion files)
1. `<ID-1>` (`src/driver.c`, `test/driver-test.c`) -> 2. `<ID-2>` -> `LAND-VERIFY-<WAVE>`

## Landed Pending Cleanup (should be empty after every wave)
- none
```
