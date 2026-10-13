---
name: workspace
description: jj-workspace isolation law (ALL projects) — ANY agent dispatch that EDITS repo files runs in its own jj workspace under ~/hk/workspace. Supervisor sets up + lands (linear history); agents NEVER touch jj. Use before every coding/refactor/prototype dispatch, mandatory when parallel.
---

# WORKSPACE LAW (vic, global) CVMN — parallel coding w/o mainline risk. HARD GATES.

## WHEN (no judgment call)
ANY dispatch that edits repo files (rung/typesmith/hunter-prototypes/isolate-repros-in-repo/superhaiku swarm) ⟹ ISOLATE. Read-only agents (probe/reader/sweep/judge/lawyer) need none.

## SUPERVISOR DUTIES (caller owns ALL of this — never the agent)
1. `vic-ws new <task-name> [rev]` → prints workspace path (~/hk/workspace/<repo>-<task>).
2. Spec carries: `WORKSPACE: <abs path> — ALL file ops INSIDE it. jj/git commands FORBIDDEN (any of: commit/new/squash/describe/abandon/rebase/workspace/git *). Violating = work DISCARDED.`
3. One workspace per agent (k-shot ensemble ⟹ k workspaces). Disjoint-dep lanes law still applies for BUILD cost, not safety — safety now comes from isolation.

## LANDING (orchestrator ONLY, linear history)
deliverable → vic-reviewer audits the WS DIFF → ACCEPT: `vic-ws land <name>` (squash into current @, forget, rm) in DEPENDENCY ORDER, one at a time → REJECT/ensemble-loser: `vic-ws drop <name>` (mainline untouched, zero trace).
- CONFLICT on land = two agents touched same region ⟹ partition error: drop one, re-spec — NEVER hand-merge inside agent work.
- NO landing while other agents still writing in their workspaces against the same files.
- Mainline stays LINEAR: land = squash-into-@, never merge commits, never history rewrites of landed work.

## AGENT LAW (goes verbatim in every coding-agent spec)
Work ONLY inside assigned workspace path · jj/git = FORBIDDEN, all of them · never cd above workspace · deliverable = files in workspace + report; landing is not yours · workspace missing/wrong = `SPEC GAP`, stop.

## WHY HARD (receipts)
commit-while-agent-writes snapshotted agent WIP into supervisor commits (gate-7 lineage) · shared-working-copy edits caused spurious agent build failures · one rogue `jj new` from a worker forks mainline silently. Isolation makes all three UNREPRESENTABLE.
