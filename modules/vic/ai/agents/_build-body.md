## How to land

★ **You land §3a only** — the gating oracle. List any §3b item (cell suites,
planted violations, censuses, enforcers, byte-parity) in your report under
*guarantee deferred*; never build it here.

1. **Baseline before you change anything**, so you can attribute every later
   red. Record what you got. **Measure it yourself** — a figure
   from the spec was true of a different tree.
2. Implement the spec's mechanism and §3a.
3. Re-run the suites and **attribute every delta**.
4. **Verify the artefact changed before you read any suite.** A scripted edit
   that throws part-way can roll back every replacement and leave the tree
   untouched; the suite then returns the _old_ tree's numbers and they look like
   success. Diff, or check the mtime, or grep for the new text — then measure.
   This also guards the next step: **the seed is itself an edit with the same
   failure mode.** A seed that silently no-ops leaves the cell green, and the
   honest reading of that green is "this cell does not discriminate" — so you
   would file a finding against a sound cell.
5. Run the spec's acceptance cells, then **drive each one RED and read the
   output**. Break the thing the cell claims to catch — replace the message with
   a sentinel, restore the removed guard, delete the arm the cell names — and
   confirm the cell actually fails. A cell you have only ever seen green has not
   been shown to discriminate. A red/green table you were handed was evaluated
   against the tree as it stood before your edit — inheriting it is relaying, not
   measuring.

★ **A red on first sight is a FINDING, reported verbatim — never a fixture
edit.** If a cell flips that the spec did not enumerate, **stop and report
it**.

**You are done when the suite is green on the clean tree and you have shown it
red in the same run, the seed is removed, and the tree's digest is back where it
started.** Report both states with their exact commands and their unpiped exits.
A green you have never seen fail is a claim about a suite you have not tested.

**A script you land must distinguish "no results" from "could not measure."**
The rule above governs the cell you test; this one governs the instrument you
ship, and it is the half that goes unchecked. The mechanism is an error consumed
as an empty value — a `.get(k, [])` default, a `|| true`, a swallowed
`2>/dev/null`, an unchecked exit on a subprocess that writes its error object to
stdout — and the output is a clean-looking zero that hides a defect for weeks. ⇒ check the exit of every
command you shell out to, and **before you report it green, run it once with its
data source unavailable and confirm it SAYS SO rather than reporting zero.**

## Landing discipline

- **One report per landing.**
- **Format first**; a first-pass non-zero exit means it changed files, so re-run
  until clean.
- **Commit path-scoped**: `git -C <repo> commit -m "…" -- <explicit paths>`.
  Never `git add -A`, never `git add .`, never a bare `commit` (it takes the
  whole index), never `--amend` without a pathspec. A bare commit has swept
  another writer's staged work into a push.
- **No `Co-Authored-By` and no `Claude-Session:` trailers**, in any commit,
  ever.
- `git add` new test files **before** the collecting run — untracked test files
  are silently absent from a suite, which reads as a clean pass.
- Push, then re-verify clean and matching origin **at the final landed
  revision**.
- ★ A push moves the whole branch, not your paths. If anything unexpected is
  committed locally, stop.

## Working with terse feedback

Expect short corrections. You hold the spec and the session context, so two
words are often enough: _"Wrong repo."_ · _"Path-scope it."_ · _"That red is a
finding."_ **Apply exactly what it says and continue** — the
correction is the whole instruction, not the visible part of a larger redesign.

## Revert and re-scope

**When an approach goes wrong, say so and let the orchestrator revert.** Narrowing scope after a revert reliably beats incrementally
repairing a bad approach — and a half-repaired approach is harder to judge than
a clean one. After a revert, implement only what is explicitly asked.

## Reference existing code

When told to match an existing pattern, **read the referenced files first**. A
pointer to a working sibling carries the implicit requirements — naming, error
shape, test placement — that a description would miss.

## Hand off

- The spec is wrong or incomplete → **gen-spec**. Report the gap and stop; the design is theirs.
- You need a measurement you cannot take within scope → **gen-scout**.
- Your landing needs judging → **gen-gate**.
