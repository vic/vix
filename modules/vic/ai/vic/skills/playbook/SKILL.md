---
name: playbook
description: Playbook system (ALL projects) — freeze verified expert procedures in <proj>/vic/playbooks/*.md so cheaper model tiers execute recurring task classes near-expert with zero deviations. Use before dispatching any recurring task class, and immediately AFTER any expensive solve to freeze the procedure.
---

# PLAYBOOK LAW (vic, global) — expensive insight runs ONCE, then becomes cheap procedure

**Stack:** `/vic-stack` — recall `quipu` evidence before writing a playbook; record every frozen playbook path in `quipu`.

**Assets in this skill:**
- `references/playbook-template.md` — concise `<= 60`-line playbook template with anti-rot symbol anchors, oracle + negative-control templates, and trap receipts.
- `scripts/playbook-lint.sh` — validates playbooks (`<= 60` lines, zero hardcoded line numbers, required sections `WHEN`/`STEPS`/`ORACLE`/`TRAPS`/`DONE`, zero unfilled placeholders).

---

## 1. Why playbooks beat bigger models

Strong-model value is **decisions**. A playbook pre-makes those decisions (exact file boundaries, invariants, oracle shape, armed mutant pattern, known traps, exact step order). What remains is mechanical execution -> a cheaper tier executes near-expert with 8x first-run-green reliability.

---

## 2. Operational workflow

1. **Before dispatching any task:** Check `<proj>/vic/playbooks/`.
   - **Match found:** Reference the playbook verbatim (`"Follow <playbook>; any deviation -> SPEC GAP back"`), supply only the thin task parameters, and drop **ONE model tier** (`opus -> sonnet`; `sonnet -> haiku` if the oracle is 100% mechanically checkable).
   - **No match, but recurs `>= 2` more times:** Solve once at the appropriate tier, verify green + mutants, then immediately freeze as a playbook via `vic-scribe`.
2. **Anchor by symbol/text, NEVER by line numbers:** Line numbers rot after the next commit. Locate targets via `codegraph` symbol names or exact `rg` anchor text.
3. **Maintain like load-bearing infrastructure:**
   - If a playbook causes a wrong step, fix it in the **SAME session** (never leave broken infra on disk).
   - If superseded, mark `STATUS: DEAD (<reason> -> <replacement>)` inside and keep it to prevent re-walking the dead path.
   - Run `scripts/playbook-lint.sh <file>` before committing any playbook.
