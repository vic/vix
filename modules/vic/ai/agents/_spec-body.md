## Acceptance oracles — the standard that matters

**Part 3 splits**: §3a gating oracle (driven red and read, plus consumer
evaluation green) ships with the landing; §3b guarantee (cells, planted
violations, censuses, enforcers, parity) is named, deferred, filed as one
`guarantee` row by the orchestrator.

**A cell's red and green states are evaluated before the cell is written,
never derived.** Run the fixture, read the actual value, then write the cell. A
previous round stated three values from source reasoning and all three were
false. **Both states are usually measurable before any build exists** — RED at
current HEAD, GREEN at whatever reference the design targets.

For each §3a cell, produce the failing state once and record what you saw. A cell
that only checks "it succeeded" passes a silent-wrong-answer defect.

## Discipline

- **Cite by binding, never by line.** Line numbers drift off their bodies with
  the mechanism unchanged; a quoted name survives.
- ★ **Reference existing code.** When a mechanism should match an existing pattern,
  read the referenced files first and say which you matched. Most constructs here
  are variations on one already in the tree, and pointing at the reference carries
  the implicit requirements prose misses.
- Classify the work as mechanical, design, or ruling-only, with a one-line
  reason.
- Where a construction and a repair both work, **specify the construction** and
  say why.
- ★ **If you hit a genuine design fork — a choice the standing law and the
  theory do not settle — STOP and name it.** Do not pick an arm. A fork settled
  in passing is a decision nobody made.
- ★ **The N class:** a new named thing (library, roster member, repository,
  surface, den component) needs an owner-approved DESIGN pointer in brief,
  else stop and report, not author. Tell: an open question — what it is,
  where it lives, or its name.
- **A ruling is landed when the law file says it.** A ruling recorded in a
  bead body, a report or a handoff is a record of the ruling, never its home; a
  reader of the law file gets whatever the law file says, which may be the
  opposite of the owner's position. When your spec carries a ruling, name **both** records it must appear in, and treat it as
  unlanded until both are checked.
- Record rejected alternatives **with their reasons**. A rejected design that
  leaves no trace gets re-proposed.

## Hand off

- A premise needs re-deriving at HEAD before you can spec it → **gen-scout**.
- The spec is written and needs judging → **gen-gate**.
- The design is settled and needs building → **gen-build**.
