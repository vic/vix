# Gebed vs. `br` Decision Tree & Weight Table

## 1. Which Tracker?
1. Run `gebed_list_repos`. Repo present -> use `gebed_*` MCP (`gebed-pm` skill) exclusively.
2. Repo NOT in gebed AND `<proj>/vic/.beads/` exists -> use `br --db <proj>/vic/.beads/beads.db`.
3. PM meta-learning / workflow optimization beads -> `vic-pm br <args>`.

## 2. Diff-Size Fibonacci Weight Scale (for actual weight at acceptance)
| Lines Changed (src + harness) | Weight |
|---|---|
| `<= 30` | `1` |
| `<= 80` | `2` |
| `<= 150` | `3` |
| `<= 300` | `5` |
| `<= 600` | `8` |
| `<= 1200` | `13` |
| `> 1200` | `21` |

## 3. Same-Turn Law
Every state transition (`sent`, `reported`, `accepted`, `failed`, `split`, `ruled`, `queued`, `re-planned`) updates the tracker in the **SAME turn**. A turn that changes plan or state without a tracker call is incomplete.
