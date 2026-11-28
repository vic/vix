# Playbook Template (`<proj>/vic/playbooks/<slug>.md`, strictly <= 60 lines)

```markdown
# PB: <task-class> (tier: <haiku/low | sonnet/med> with this PB; status: ACTIVE)

## WHEN
Use when: <exact trigger condition>. Do NOT use when: <exclusion / escalation boundary>.

## STEPS (locate by symbol/codegraph or exact text — NEVER memorized line numbers)
1. Locate `<SymbolName>` via `codegraph_search` / `rg`.
2. Write RED check `<check-pattern>` first; confirm exact failure.
3. Implement minimal change per invariant `<invariant>`.
4. Run build + multi-compiler + sanitizer + golden checks (`> out; echo EXIT=$?`).
5. Run armed mutant (`scripts/mutant-runner.sh`) and verify clean-restore SHA-256.

## ORACLE & NEGATIVE CONTROL
- **Oracle:** `<exact command + expected invariant>`
- **Mutant:** `<condition/constant edit at product site -> expected FAIL name>`

## TRAPS (measured from first solve — DO NOT repeat)
- <Trap 1>: <symptom> -> <prevention>
- <Trap 2>: <symptom> -> <prevention>

## DONE (pasteable evidence list)
- `RED` output · `GREEN` 0-warn counts · `MUTANT` FAIL + clean-restore SHA · `PERF` gate line · `diff --stat`
```
