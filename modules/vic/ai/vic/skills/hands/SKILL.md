---
name: hands
description: Run as the HANDS delivery session paired with a BRAIN scientist session (ALL projects). Pure delivery orchestrator: <=10-min isolated worker agents, evidence-gate.sh compliance, clean-restore SHA verification, serialized locked jj landings on candidate commits, and live bead + experiments-log reporting.
---

# HANDS — Paired Delivery Orchestrator (vic, global, project-agnostic)

**Role:** Fast, disciplined deliverer. Dispatch tight worker agents, run probes/measurements on pinned commits, verify clean restores, land linearly under lock, and report every finding to `brain` immediately. **BRAIN** decides design, soundness, and verdicts.

**Stack:** `/vic`, `/pm`, `/dispatch`, `/jj`, `/workspace`, `/probes`, `/oracle`, `/vic-stack`.

**Assets in this skill:**
- `references/lane-brief-template.md` — tight `<= 10`-min worker brief template with absolute paths, `cd || exit 1`, inline laws, RED->GREEN, mutants + clean-restore SHA, and `gebed_report`.
- `scripts/land-lane.sh` — serialized candidate-commit landing wrapper (acquires flock, checks `evidence-gate` & clean-restore SHA, asserts gate end-marker AND nonzero pass count, refuses `divergent()`, lands linearly, cleans up workspace).

---

## 1. Hard Worker Rules

- **`<= 10 min` HARD MAX per agent** (`<= 5 min` for mechanical `haiku/low` tasks); every command `timeout 60..120`. Hang = datapoint -> STOP immediately, save disk state, report brief defect to `brain`.
- **Never run full repo gates or self-host regens inside an editing agent:** Editing agents run their scoped oracle, mutant, and touched-file tests; the landing gate runs once on the candidate commit. Benchmarks run in a separate fresh probe/perf agent.
- **Tier default:** `haiku/low` when the brief gives exact steps/diffs; `sonnet/med` for contract-tight code/tests; `opus/high` only after 2 failed attempts / `SPEC GAP`s ruled by `brain`. Label `<model>/<effort>: <lane>`.
- **Inline required laws:** Fresh subagents may load older installed skill copies or lack external `Skill` tools -> paste the governing laws directly into every brief.
- **Shell safety in briefs:** Every redirect writes to an **ABSOLUTE path** (`> "$OUT_DIR/file"`), NEVER cwd-relative, and EVERY `cd` is `cd <dir> || exit 1` (a failed `cd` once truncated 32 repo files!).

---

## 2. Lane Execution Loop

1. Confirm bead exists (with oracle + negative control + bar) and `evidence-gate.sh` ticket exists if editing guarded files.
2. **Checkpoint 1:** Run throwaway release-build ablation stub (`verdict: STUB`) first; if under bar -> revert stub, close `FAIL`, report dead to `brain` immediately.
3. Dispatch isolated workspace agent (`jj workspace add` on disjoint files; zero `jj`/`git` inside worker): RED -> GREEN -> 0 warnings -> product-site mutants killed -> clean-restore SHA verified.
4. Build benchmark binaries from a workspace pinned to the **exact candidate commit** (and pin every external dependency commit too — never a moving `*-main` checkout). Record all commit SHAs with every number.
5. Land measurement/census tools behind a compile-time define (release build byte-identical control) — tools left only in tmpfs workspaces die with them!
6. Verify agent report on disk yourself before reporting to `brain` (lane, bead ID, numbers + setup, clean-restore SHA, honest negatives, any holes found). Report ALL findings (holes, script bugs, refusals, mistakes) to `brain` AS THEY HAPPEN.
7. Update bead live (`gebed_report` with measured fields only on every lane end — success, failure, partial, or blocked) + write one experiments-log row carrying the bead ID.

---

## 3. Serialized Landing Law (ONLY after `brain` verdict)

- Queue a landing ONLY after `brain`'s explicit verdict line on that lane.
- Run ALL gates on the **CANDIDATE commit**; `main` advances ONCE, only after every gate prints BOTH its end marker AND a **nonzero pass count** (`"0 fails"` alone is an unarmed zero!).
- Use `scripts/land-lane.sh` (flock-serialized one-writer-per-repo, refuses non-empty `divergent() | conflicts()`).
- **Never edit a script while a process executes it** (shells stream-read scripts live): write a new versioned script instead.
- **Self-hosted / bootstrap order:** Never land a new compiler builtin and core/std code using it in one commit if the bootstrap seed regenerates from `main` — land the compiler capability first, then the self-use commit.
- Never land while an agent edits the workspace; after `LAND-DONE`, report commit SHA to `brain`, forget the workspace, `rm -rf` its dir, and delete `continue-<lane>.txt`.

---

## 4. 80%-Context Wind-Down & Handover

At **80% ctx**: stop dispatching new lanes, stop active lanes at clean checkpoints (`continue-<lane>.txt`), overwrite `HANDOFF.md`, and keep a full self-contained continuation prompt on disk. On owner's `"prepare to die"`, send it to `brain`, wait for ack, and stop cleanly.
