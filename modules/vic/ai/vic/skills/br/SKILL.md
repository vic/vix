---
name: br
description: Issue, bead, and epic task management law (ALL projects) — gebed-pm MCP first when registered, fallback to beads_rust (br/bd) CLI with explicit --db paths, evidence-before-close gate, real-only dependency edges, and jj sync (zero mutating git). Use whenever managing tasks, epics, dependencies, or reporting work outcomes.
---

# BR / BEADS TASK MANAGEMENT LAW (vic, global)

**Stack:** `/vic-stack` (mirror bead status changes to `quipu` `ledger:<proj>/bead/<id>` with `replace_snapshot: true`) · `/jj` (commit/sync via `jj`, NEVER mutating `git`).

**Assets in this skill:**
- `references/gebed-vs-br.md` — clean decision tree (`gebed-pm` MCP vs. `br` CLI), per-stage `gebed_report` rules, and explicit `--db` path law.
- `scripts/bead-close-check.sh` — verifies required close evidence (read-back title, commit hash, oracle output, measured report reminder) before closing any bead.

---

## 1. Gebed First (binding when repo is registered in gebed)

If the repo is registered in `gebed`, load skill `gebed-pm` and use `gebed_*` MCP tools — NOT `br`:
- **Plan:** Create epic + at least the next 4 critical-path beads with **real-only** `blocks` edges (only where a later task reads an earlier task's output — phantom edges block starts), planned Fibonacci `weight:N` label, and planned `gebed_set_schedule` length (never overwrite the planned length later).
- **Dispatch:** `gebed_set_status in_progress` in the SAME turn.
- **Accept / Fail / Block:** Submit one `gebed_report` **per stage** (`impl-agent`, `perf-agent`, `design`) with ONLY that stage's minutes and **measured fields only** (`outcome`, `weight`, `complexity`, `minutes`, `attempts`, `tokens`, `costCents`, `testsPass`, `testsFail`, `confidence`, `findings`). Omit unknown fields — NEVER send guessed `0`. Only lane owners send `capacity: 1`.
- **Fallback:** If `gebed` reports `gebed is not reachable`, note it in 1 line, use `br`, and backfill `gebed` when reachable.

---

## 2. `br` CLI Workflow (when repo uses `.beads/` without gebed)

**Explicit DB trap:** Always pass `--db <proj>/vic/.beads/beads.db` when running from outside the project root (otherwise `br` hits the wrong home DB). For PM meta-optimization beads, use `vic-pm br ...`.

```sh
br ready                                            # open, unblocked, actionable work
br list --status=open                               # all open beads
br show <id>                                        # read back exact title + deps BEFORE comment/close
br create --title="..." --description="..." --type=task --priority=2
br dep add <issue> <depends-on>                     # real data/file dependencies ONLY
br update <id> --status=in_progress --assignee="<model>/<effort>: <lane>"
br comments add <id> "evidence: <commit> <oracle> <perf>"
br close <id> --reason="commit <sha>: <verified evidence>"
br sync --flush-only                                # export DB to JSONL inside vic/.beads/
```

- **Priority:** `0` (P0 critical/soundness) · `1` (high) · `2` (medium) · `3` (low) · `4` (backlog) — always integers `0..4`.
- **Types:** `task`, `bug`, `feature`, `epic`, `chore`, `docs`, `question`.

---

## 3. Evidence-Before-Close & JJ Session Protocol (ZERO `git`)

1. **Read the bead title back** (`br show <id>` / `gebed_get_bead`) before commenting or closing — prevents wrong-ID comments.
2. **Never close without verified evidence:** Run `scripts/bead-close-check.sh --id <id> --commit <sha> --oracle "<output>"`.
3. **Sync and commit via `jj` ONLY (never `git add`/`git commit`/`git push`):**
   ```sh
   br sync --flush-only
   jj -R vic st                     # stop-gate: inspect before committing
   jj -R vic commit -m "beads: sync <id>"
   jj -R vic bookmark set vic -r @-
   ```
   Never push autonomously — pushes require explicit owner approval.
