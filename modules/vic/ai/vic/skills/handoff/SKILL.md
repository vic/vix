---
name: handoff
description: Session continuity & bad-network checkpointing protocol (ALL projects) — HANDOFF.md (<=25 lines, overwrite), state.md (prepend), spec-to-disk, mid-work checkpointing, and zero-loss session handover. Use at task boundaries, before risky long ops, on every major discovery, and ALWAYS before session end. Enforced globally by stop-gate.sh at ctx >= 70%.
---

# HANDOFF & CONTINUITY LAW (vic, global)

Network drops and context resets kill sessions; **disk survives, context does not**.

**Stack:** `/vic-stack` — mirror `HANDOFF.md` and `state.md` writes to `quipu` (`ledger:<proj>/handoff/<YYYY-MM-DD>` with `replace_snapshot: true`) and notify peer sessions via `ircc_msg`.

**Assets in this skill:**
- `references/handoff-templates.md` — exact `HANDOFF.md` (<= 25 lines) and `state.md` (<= 15 lines prepend) templates plus handover verification checklist.
- `scripts/handoff-check.sh` — mechanically validates `<proj>/vic/HANDOFF.md` (<= 25 lines, freshness <= 30 min, required fields `UPDATED`/`DOING`/`NEXT-CMD`/`THEN`/`OPEN`/`FILES`/`BURN`, zero unfilled placeholders).

---

## 1. Canonical Resume File (`<proj>/vic/HANDOFF.md`)

- **OVERWRITE** (never append history — history goes to `state.md`).
- **Hard budget: `<= 25 lines`.** Fresh sessions resume cold in 4 reads (`<= 4K` tokens) from this file.
- **Required fields:** `UPDATED` (UTC + commit hash) · `DOING` (in-flight lanes/beads/brief SHA-256s) · `NEXT-CMD` (verbatim runnable command) · `THEN` (next 2 critical-path rungs) · `OPEN` (blockers/questions) · `FILES` (uncommitted edits + active workspaces) · `BURN` (`<model>/<effort> ~<tok> <mins>m`) · `RULES PULSE` (top 1–2 live traps).
- **Mandatory update triggers:** every accepted task · every lane dispatch/land · before risky long op · ctx `>= 70%` (`stop-gate.sh` blocks stop until fresh) · session end.
- **Ownership boundary:** Design and implementer maintain separate `HANDOFF.md` / `state.md` paths; NEVER edit or `jj restore` another role's notes.

---

## 2. Mid-Work Checkpointing (not only session end)

- **Checkpoint discoveries as found:** Record root causes, ruled-out paths, probe tables, and derivation steps to disk immediately so a dropped connection loses zero reasoning.
- **Spec-to-disk rule:** Any spec/brief `> 5 lines` lives in a staged file (`<ID>.md` + SHA-256), never only in a prompt string.
- **Dead agent != lost work:** Agents append per-step reports; after any agent death, inspect disk (`ls`, `jj -R <ws> st`, `sha256sum`) before re-dispatching — salvage and verify beat redo.

---

## 3. Task-End Checklist (every accepted task)

1. **`state.md`:** PREPEND a block `<= 15 lines` — commit hash, keystones, test/mutant/perf tallies, uncommitted notes, `NEXT`, `BURN`, and any `OWN MISTAKE` (`what happened -> rule`).
2. **`HANDOFF.md`:** Overwrite cleanly (`<= 25 lines`); verify with `scripts/handoff-check.sh --repo .`.
3. **Track / notes:** Landed -> `LAW` · falsified -> `DEAD` with receipt (never deleted) · follow-up -> `OPEN` / queue rider.
4. **Pristine tree:** Revert all temporary investigation traces (`diff` clean); re-verify green tests after revert; keep env-gated probes.
5. **Tracker + memory:** Update issue tracker (`gebed_report` / `br`) + mirror to `quipu` in the same turn.

Never end a session leaving: an unreported failing tree · an unaccounted in-flight agent · a live mutant on disk · or a spec living only in conversation memory.
