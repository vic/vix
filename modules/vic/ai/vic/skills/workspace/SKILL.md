---
name: workspace
description: jj-workspace isolation law (ALL projects) — ANY agent dispatch that EDITS repo files runs in its own jj workspace under ${XDG_RUNTIME_DIR:-/tmp}/jj-ws (wiped on reboot). Supervisor sets up + lands (linear history); agents NEVER touch jj. Use before every coding/refactor/prototype dispatch, mandatory when parallel.
---

# WORKSPACE LAW (vic, global) CVMN — parallel coding w/o mainline risk. HARD GATES.

## WHEN (no judgment call)
ANY dispatch that edits repo files (rung/typesmith/hunter-prototypes/isolate-repros-in-repo/superhaiku swarm) ⟹ ISOLATE. Read-only agents (probe/reader/sweep/judge/lawyer) need none.

## LOCAL REPO LAW (every repo under ~/hk, vic 2026-10-29)
- jj ALWAYS. git-only repo ⟹ `jj git init --colocate`, no ask. Mutating git (commit/add/stash/checkout/switch/reset/rebase/merge/restore) = FORBIDDEN; jj equivalents only.
- `vic/` (notes, status, HANDOFF, state) = own jj workspace `vic` of the SAME repo, started from `root()` (commit 000000000000), bookmark `vic`. Never on main. Create: `jj workspace add --name vic -r 'root()' vic`. Commit inside it: `jj -R vic commit -m ...` + `jj -R vic bookmark set vic -r @-`.
- beads db lives in `vic/.beads` (tracked w/ vic/). Repo root `.beads` = symlink to `vic/.beads`, listed in `.git/info/exclude` (local, never committed).
- Session start check: missing `.jj`, `vic/.jj`, or `vic/.beads` while `.beads` exists ⟹ fix first.

## SUPERVISOR DUTIES (caller owns ALL of this — never the agent)
1. Create: `mkdir -p $XDG_RUNTIME_DIR/jj-ws/<repo>` then `jj workspace add $XDG_RUNTIME_DIR/jj-ws/<repo>/<name>` → that path is the workspace.
2. Spec carries: `WORKSPACE: <abs path> — ALL file ops INSIDE it. jj/git commands FORBIDDEN (any of: commit/new/squash/describe/abandon/rebase/workspace/git *). Violating = work DISCARDED.`
3. One workspace per agent (k-shot ensemble ⟹ k workspaces). Disjoint-dep lanes law still applies for BUILD cost, not safety — safety now comes from isolation.

## LANDING (orchestrator ONLY, linear history)
deliverable → vic-reviewer audits the WS DIFF → ACCEPT: from the main repo run `jj squash --from <name>@ --into @` (`-f/--from`, `-t/--into`), in DEPENDENCY ORDER, one at a time → REJECT/ensemble-loser: `jj abandon <name>@` (mainline untouched).
- HARD: IMMEDIATELY after land or abandon, supervisor runs: (a) `jj -R <ws-dir> st` (snapshots the agent's edits; jj only snapshots the workspace a command runs in), (b) `jj workspace forget <name>` from the main repo, (c) `rm -rf <ws-dir>`. End of every wave: `jj workspace list` must show only `default`; leftovers get (a)-(c). NEVER leave a workspace behind.
- CONFLICT on land = two agents touched same region ⟹ partition error: drop one, re-spec — NEVER hand-merge inside agent work.
- NO landing while other agents still writing in their workspaces against the same files.
- Mainline stays LINEAR: land = squash-into-@, never merge commits, never history rewrites of landed work.

## AGENT LAW (goes verbatim in every coding-agent spec)
Work ONLY inside assigned workspace path · jj/git = FORBIDDEN, all of them · never cd above workspace · deliverable = files in workspace + report; landing is not yours · workspace missing/wrong = `SPEC GAP`, stop.

## WHY HARD (receipts)
commit-while-agent-writes snapshotted agent WIP into supervisor commits (gate-7 lineage) · shared-working-copy edits caused spurious agent build failures · one rogue `jj new` from a worker forks mainline silently. Isolation makes all three UNREPRESENTABLE.
