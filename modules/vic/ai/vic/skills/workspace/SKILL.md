---
name: workspace
description: Isolated jj-workspace law for parallel agent execution (ALL projects) — ANY agent dispatch that edits repo files runs in its own jj workspace under ${XDG_RUNTIME_DIR:-/tmp}/jj-ws/<repo>/<lane>. Supervisor creates, snapshots, audits, lands linearly, and deletes; worker agents NEVER run jj/git. Use before every coding/refactor/prototype dispatch, mandatory when running parallel lanes.
---

# WORKSPACE LAW (vic, global) — parallel coding with zero mainline risk

**Stack:** `/vic-stack` (record landed workspaces in `ledger:<proj>/landed/<slug>`), `/jj` (all `jj` laws, revsets, and locked landing), `/lanes` (disjoint file & test-count partitioning).

**Assets in this skill:**
- `references/workspace-contract.md` — verbatim worker workspace contract block, disjointness checklist (source + test/count files), and wave cleanup protocol.
- `scripts/ws-create.sh` — creates a clean isolated workspace from a verified tip (refuses dirty/divergent repos).
- `scripts/ws-audit.sh` — cross-checks `jj workspace list` against runtime dirs and flags stale/orphaned workspaces.

---

## 1. When isolation is mandatory (zero judgment calls)

- **ANY dispatch that edits repository files** (coding, refactoring, type-enforcement, repro-in-repo, mutant runs, ensemble k-shots) **MUST** run in its own isolated `jj` workspace.
- **Read-only agents** (`vic-probe` reading committed files, `vic-reader`, `vic-sweep`, `vic-judge`, `vic-lawyer`) need no workspace — unless building scratch probe binaries that write into `build/` while another lane builds (give them `build/probe-<id>/` or their own workspace).

---

## 2. Disjointness rule (prevents land conflicts & wasted hours)

Two parallel workspaces are safe ONLY when their `FILES` lists are strictly **disjoint across BOTH**:
1. **Production source files** (including shared headers), AND
2. **Test registration / global count-assertion files** (shared test `main`, shared integration count assertions, build manifests).
- Each parallel lane gets its own named registration anchor line or its own test file.
- Tasks sharing central wiring or count assertions MUST be **serialized explicitly** in one lane.
- Every lane has its own `build/`, scratch, cache, and log paths — lanes share ZERO output or verdict files.

---

## 3. Supervisor lifecycle (workers NEVER touch VCS)

1. **Create with explicit `-r <main-tip>`:** `jj workspace add` forks off `@-` (parent), NOT `@` — always pass explicit `-r <main-tip>`:
   ```sh
   scripts/ws-create.sh --repo . --name <lane> --rev <main-tip>
   ```
   Workspace path: `${XDG_RUNTIME_DIR:-/tmp}/jj-ws/<repo>/<lane>`. Never share a build artifact directory (e.g., `CARGO_TARGET_DIR` / `build/`) across workspaces — shared build dirs serve stale binaries and fake green runs.
2. **Embed verbatim worker contract** (`references/workspace-contract.md`) in the brief: exact workspace path, explicit zero-VCS rule, foreground builds only, build from workspace path itself. Never run even read-only `jj` commands in sibling workspaces while agents are mid-flight (snapshots rewrite shared op-log descendants and turn sibling workspaces stale).
3. **Snapshot BEFORE squash/forget (critical order):**
   - Snapshot edits FIRST: `jj -R <ws> st` AND confirm `jj diff -r '<name>@' --stat` is non-empty (squashing before snapshotting silently lands 0 files; forgetting + `rm -rf` before snapshotting destroys work!).
   - Verify `diff --stat` matches brief `FILES` exactly, clean-restore SHA-256 matches (`0` live mutants), and diff reviewed against contract.
   - If `jj workspace update-stale` checks out an empty commit, recover via `jj log -r 'all:<change>'` -> `jj edit <non-empty>` -> `jj abandon <empty>`.
4. **Land linearly (one lane at a time, under lock):**
   Use `/jj` `scripts/jj-land-linear.sh` (or `jj squash --from <name>@ --into @` + `jj commit`).
   - **Land conflict** = partition error -> abandon loser (`jj abandon <name>@`), re-spec cleanly. NEVER hand-merge agent work.
   - **Rejected / ensemble loser:** `jj abandon <name>@`, then immediately forget & delete dir.
5. **Immediate cleanup & wave audit:**
   Always run `jj -R <ws> st` -> `jj workspace forget <name>` -> `rm -rf <ws>` immediately after land/abandon. At wave end, run `scripts/ws-audit.sh --repo .` — zero leftover lane workspaces allowed.

---

## 4. Local repo & `vic/` orphan workspace law

- Colocate git-only repos immediately (`jj git init --colocate`). Mutating `git` is FORBIDDEN.
- Project notes (`vic/` — `HANDOFF.md`, `state.md`, `lanes.md`, `.beads/`) live in orphan workspace `vic` rooted at `root()`, bookmark `vic` (`jj workspace add --name vic -r 'root()' vic`), never on `main`.
- Root `.beads` symlinks to `vic/.beads` and stays in `.git/info/exclude`.

---

## 5. Why hard (measured receipts)

- Committing while an agent wrote in the same checkout snapshotted half-finished WIP into mainline.
- Editing shared checkouts mid-build caused spurious build failures and wasted 15+ minutes per collision.
- Cross-lane interactive squash across dirty workspaces landed live mutants into history.
- Building from the main path instead of the workspace path silently skipped newly added files.
- Isolation + SHA-gated linear landing makes every one of these failure modes **unrepresentable**.
