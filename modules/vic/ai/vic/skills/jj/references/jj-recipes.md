# JJ Recipes, Revsets, and Safe Recovery

## 1. Essential Revsets

| Goal | Revset / Command |
|---|---|
| Last 10 commits with changed files | `jj log -r 'ancestors(@,10)' --name-only --no-pager` |
| Any broken state (MUST be empty before land) | `jj log --no-graph -r 'divergent() \| conflicts()' -T 'change_id.short() ++ " " ++ commit_id.short() ++ "\n"'` |
| All local mutable commits | `jj log -r 'mutable()'` |
| Commits on current line back to main | `jj log -r 'main..@'` |
| View a specific workspace's working copy | `jj -R <ws-path> st && jj diff -r '<name>@'` |
| Read a file at parent without touching `@` | `jj file show --ignore-working-copy -r @- <path>` |
| List all open workspaces | `jj workspace list` |

## 2. Parallel Lane Workspace Lifecycle (Supervisor Only)

```sh
# 1. Create isolated workspace from verified main tip
WS="${XDG_RUNTIME_DIR:-/tmp}/jj-ws/$(basename "$(jj root)")/<lane>"
mkdir -p "$(dirname "$WS")"
jj workspace add --name "<lane>" "$WS" -r <main-tip>

# 2. Agent works ONLY inside "$WS" (runs ZERO jj/git commands)

# 3. Snapshot agent edits (mandatory before diff/land)
jj -R "$WS" st
jj diff -r '<lane>@' --stat

# 4. Option A — Commit in lane & rebase linearly onto main tip (preferred for multi-lane waves)
jj -R "$WS" commit -m "<ID>: <title>"
jj rebase -r '<lane>@-' -d <main-tip>
jj bookmark set main -r '<lane>@-'

# 4. Option B — Squash directly into clean @ on main tip
jj squash --from '<lane>@' --into @
jj commit -m "<ID>: <title>"

# 5. Abandon a failed or losing workspace cleanly
jj abandon '<lane>@'

# 6. Always forget + remove immediately after land or abandon
jj workspace forget "<lane>"
rm -rf "$WS"
```

## 3. Safe Recovery Playbooks

### A. Rescuing a divergent change (`divergent()` non-empty)
1. Inspect both twins: `jj log -r 'divergent()' --stat`
2. Diff twin A vs twin B: `jj diff --from <commitA> --to <commitB>`
3. Keep the clean/complete commit; abandon the stale twin: `jj abandon <stale-commit-id>`
4. Verify `jj log -r 'divergent()'` is empty before any further op.

### B. Undoing a mistaken VCS operation
1. Inspect recent operations: `jj op log --limit 10`
2. Preview or undo last op: `jj undo` (or restore exact op: `jj op restore <op-id>`)
3. Never recreate a "vanished" file before checking `jj op log` and `jj log --stat`.

### C. Preserving uncommitted peer notes on main `@`
If `jj st` shows uncommitted peer edits (e.g., `state.md` / `HANDOFF.md`) when you need to rebase `@` onto a newly landed commit:
- Commit them cleanly (`jj commit -m "notes: peer state checkpoint"`) OR rebase `@` onto the landed tip (`jj rebase -r @ -d <new-tip>`).
- NEVER run `jj restore` on peer note files.

### D. Updating a stale secondary workspace
If a workspace reports `The working copy is stale`:
```sh
jj -R "$WS" workspace update-stale
jj -R "$WS" st
```
Inspect before writing any files into it.
