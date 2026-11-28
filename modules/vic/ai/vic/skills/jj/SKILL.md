---
name: jj
description: Jujutsu (jj) version-control law and mastery (ALL projects) — colocated repos, jj status as stop-gate, one-writer-per-repo, zero divergent/conflict landing, isolated lane workspaces, linear history, vic/ root() orphan workspace, revsets, and safe op-log recovery. Use before ANY VCS inspection, commit, rebase, squash, workspace create/land/drop, or conflict/divergence recovery. Triggers — jj, workspace, commit, rebase, squash, land, divergent, conflict, op log, revset, colocate, linear history.
---

# JJ LAW (vic, global) — linear history, zero divergence, zero mutating git

`jj` is the ONLY permitted VCS mutation tool across local repos. Mutating `git` (`commit`, `add`, `stash`, `checkout`, `switch`, `reset`, `rebase`, `merge`, `restore`, `cherry-pick`, `clean`) is **FORBIDDEN** — use `jj` equivalents only. Invoke `jj` directly or via this skill's verified scripts.

**Assets in this skill:**
- `references/jj-recipes.md` — full revset cheatsheet, colocated setup, `vic/` orphan workspace, safe recovery, and common failure modes.
- `scripts/jj-gate.sh` — pre-op / pre-land health verifier (colocated check, `divergent() | conflicts()` zero gate, dirty working copy stop-gate, workspace audit).
- `scripts/jj-land-linear.sh` — flock-serialized linear lane landing (snapshot workspace, clean-restore SHA check, rebase/squash onto tip, verify zero divergence, forget & remove workspace).

**Related skills:** `/workspace` (parallel agent isolation contract), `/lanes` (disjoint lane scheduling), `/design-impl-workflow` (end-to-end design/impl landing loop).

---

## 1. Non-negotiable invariants

1. **Colocate git-only repos immediately:** `jj git init --colocate` (no ask needed).
2. **`jj st` is a STOP GATE — NEVER chain it:** Never write `jj st && jj new` or `jj st && jj rebase`. Run `jj st` alone, read its output, and STOP if unexpected changes exist (e.g., an implementer's uncommitted notes or an in-flight agent's edits).
3. **One writer per repository at a time:** Concurrent `jj` writes create divergent commits and "lost" work. Serialize every landing/mutation under `flock` (see `scripts/jj-land-linear.sh`). Refuse to land while `divergent()` or `conflicts()` is non-empty.
4. **Linear mainline ONLY:** Land work via linear rebase (`jj rebase -r <rev> -d <tip>`) or `jj squash --from <ws>@ --into @` — NEVER merge commits. A land conflict requiring a hand-merge of agent work is a **partition error**: abandon the lane and re-spec disjoint files.
5. **Workers run ZERO `jj` commands:** Coding, mutant, and perf subagents NEVER run `jj` (or `git`). Only the orchestrator/design lead creates workspaces, snapshots them, commits, lands, and cleans up.
6. **Snapshot BEFORE reading, squashing, or forgetting a secondary workspace:** `jj` snapshots a workspace only when a `jj` command executes inside it. Always run `jj -R <ws-path> st` AND confirm `jj diff -r '<name>@' --stat` is non-empty BEFORE `jj squash --from <name>@` or `jj workspace forget`/`rm -rf` — otherwise lazy snapshotting lands 0 files and `rm -rf` permanently destroys edits.
7. **`jj workspace add` forks off `@-` (parent), NOT `@`:** Always pass explicit `--revision <commit>` (`-r <main-tip>`) when spawning parallel lane workspaces so new lanes inherit the exact committed base, never a stale parent.
8. **Cross-workspace snapshot race & divergent-side recovery:** Never run ANY `jj` command (even read-only `jj log`) in a workspace while sibling agents are mid-flight, because every `jj` command snapshots its own workspace and rewrites shared op-log descendants, marking sibling workspaces stale. If `jj workspace update-stale` checks out an empty commit, recover via `jj log -r 'all:<change>'` -> `jj edit <non-empty>` -> `jj abandon <empty>`.
9. **Never commit while an agent is in flight in that working copy; hermetic VCS snapshotting:** A commit snapshots half-written WIP; editing modules mid-build causes spurious failures. For hermetic build tools (e.g., Nix flakes) that read VCS-tracked files only, run `jj st` to snapshot newly created files before running full checks.
10. **Never `jj restore` another session's notes & default-branch pins only:** Peer/implementer handoff and state files live in their own working copy or orphan metadata workspace — never `jj restore` them. Never pin lockfile dependencies to feature-branch revisions (only default-branch-reachable commits survive branch deletion); agents land locally and leave remote pushes/PRs to the owner.
11. **Build from the workspace path itself & clean up immediately:** Running a build from a plain/main path can silently skip new files inside a workspace. After landing or abandoning a lane: (a) `jj -R <ws> st` (confirm snapshot), (b) `jj workspace forget <name>`, (c) `rm -rf <ws>`. At wave end, `jj workspace list` shows only `default` (and optional metadata workspace).

---

## 2. Session-start & pre-land commands

```sh
# Session orientation (read-only)
jj log -r 'ancestors(@,10)' --name-only --no-pager

# Pre-operation health gate (run before any rebase/commit/land)
scripts/jj-gate.sh --repo .

# Safe locked linear lane landing (from main repo)
scripts/jj-land-linear.sh --repo . --ws /run/user/1000/jj-ws/<repo>/<lane> --name <lane> \
  --msg "<ID>: <one-line title>" [--manifest <clean.sha256>]
```

---

## 3. Local repo layout (`vic/` orphan workspace)

Project notes, handoffs, state ledgers, and beads live in a dedicated orphan workspace `vic/` rooted at `root()` (commit `000000000000`), bookmark `vic` — never polluting `main`:
```sh
jj workspace add --name vic -r 'root()' vic
jj -R vic commit -m "vic: <summary>"
jj -R vic bookmark set vic -r @-
```
Beads DB lives at `vic/.beads`, symlinked from repo root `.beads` (listed in `.git/info/exclude`, never committed).

---

## 4. Red flags — stop immediately

| Violation | Consequence / Fix |
|---|---|
| `jj st && jj new` chained over uncommitted peer notes | Moves peer notes to side branch. Run `jj st` alone first. |
| Worker subagent runs `jj commit` / `jj new` | Forks mainline silently -> discard work, tighten worker guard hook. |
| Landing while `divergent()` or `conflicts()` is non-empty | Compounds corruption -> run `scripts/jj-gate.sh`, resolve via `jj op log` first. |
| Interactive cross-lane squash across dirty workspaces | Commits live mutants into history -> land one verified lane at a time with SHA manifest. |
| `jj restore` on another session's `HANDOFF.md` / `state.md` | Destroys peer memory -> recover via `jj op log` / `jj file show`. |
| `git commit` / `git stash` / `git checkout` in colocated repo | Breaks jj working-copy tracking -> use `jj` equivalents exclusively. |
| Pushing without explicit owner request + full CI gate | Forbidden -> keep commits local until owner approves push. |
