---
name: vic-lessons
description: Lessons learned from all of vic's past agent work (rules vic gave, PM/tier calibration, per-skill lessons, tool traps). Preloaded into every vic-* agent; read before dispatching, estimating, or using jj/nix/br/shell. Grows automatically, append-only, via `vic-pm learn`.
---

# vic-lessons (append-only, grows every retro)
STACK: /vic-stack — lessons are quipu-backed: read them at task start, hand verified new ones to `#vic-shadow` or `vic-pm learn`.

Live-linked into the vix repo (modules/vic/dots/claude/skills/vic-lessons), so appends land in the repo and survive restarts and hardware moves.

## WORKER CONTRACT (every subagent, every task)
- Max 3 fix attempts. An attempt = one change + one run of the check. After the 3rd failed attempt: STOP. No 4th try, no new theory. Report `blocked` with what you tried. PM classifies the problem and decides the next step.
- Never widen scope or redesign to make the check pass.
- End EVERY run with this block (the SubagentStop hook rejects a stop without it):
```
REPORT
status: done | partial | blocked | specgap
capable: yes | no · <why: missing info, tool, access, skill, or task too big for one run>
attempts: <n>/3
class: recon | impl | debug | design | review | doc | measure | law
evidence: <cmd + decisive output line, or file path>
blocker: <precise blocker, or ->
metrics: secs=<n> tool_calls=<n> files_touched=<n>
```

## Read on demand (one level deep)
- [vic.md](vic.md): vic's rules for agents. TOP = rules vic had to repeat most.
- [pm.md](pm.md): tier, time-gate, partition, spec, verify, burn baselines.
- [skills.md](skills.md): lessons per skill/agent (oracle, probes, ensemble, workspace, handoff, vic-rung, ...).
- [traps.md](traps.md): tool traps with fixes (jj, git, shell, nix, cargo, br, codegraph, harness/MCP).

## Always apply (top lessons)
- Agent output = claim. `ls` every "written" file; paste cmd + output before "done".
- Every agent ≤5 min, foreground, explicit model + effort, label `<model>/<effort>:`.
- Tight spec + oracle + negative control ⟹ sonnet; mechanically checkable ⟹ k×haiku + judge; opus/fable only for hard reasoning.
- jj, never git; one jj workspace per editing agent; agents never run jj.
- 3 fails ⟹ stop, write the escalation note, move on.

## Add a lesson (never edit or delete lines; append only)
`vic-pm learn <vic|pm|skills|traps> "<lesson> · src:<project>/<file>"`
Only verified lessons (evidence on disk or in the ledger). Dedup is automatic.

## Appended
