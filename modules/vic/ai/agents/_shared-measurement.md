## Instrument facts — measured in this environment; each has caused a real false finding

The shell and tracker facts every run needs. Traps specific to one MCP server live
in the bank (see Memory, below).

- **The shell is zsh, not bash**, despite the tool being named Bash.
  `$pipestatus`, not `$PIPESTATUS`. Brace a rev:path — `"${sha}:lib/x.nix"`; the
  bare form silently applies zsh's history modifier and can return nothing while
  exiting 0.
- **Never name a variable `path`** — it is a tied array bound to `PATH`, and
  assigning to it makes every external command vanish silently. **`status` is
  also read-only** in zsh (that one fails loudly).
- Unquoted `$list` does **not** word-split in zsh.
- Use `/run/current-system/sw/bin/grep` for any count you report; the wrapper
  `grep` honours `.gitignore` and under-reports.
- **`grep -r` does not follow symlinks; `-R` does.** A tree of symlinks reads
  EMPTY — a clean zero over files you can `cat` by name.
- **`grep -c` counts matching LINES, and prose wraps** — a multi-word phrase reads
  0 while present. Flatten AND squeeze:
  `tr -s '[:space:]' ' ' | grep -o 'phrase' | wc -l`. `tr '\n' ' '` alone is not
  enough: it leaves the continuation line's indentation, so the phrase still
  carries several spaces and still reads 0. Three units, never interchangeable:
  `-c` counts lines, `-o | wc -l` counts occurrences, `-rc | wc -l` counts files.
  **Carry the unit in the figure.** Two readers on different units read as a
  contradiction, and the disagreement costs a round to adjudicate.
- Read exit status **unpiped**: `cmd > file; echo $?`. Piping through `tail`
  gives you `tail`'s status and truncates the domain of any absence claim.
- `2>/dev/null` turns a **missing instrument** into an **absence finding**. Do
  not silence stderr on a measurement.
- `nix eval` leaves the spine unforced — use `deepSeq`.
- Suites live at `./ci#tests`, not the root flake. **`0/0` is a FALSE PASS.**
  Count both ❌ and ☢️, and check the collected-cell count agrees with the
  summary line.
- Read tracker bodies with `STATUS/br-cat.sh <id>`, never a bare `br show` (a
  measured 48x regression that also re-imports comment sediment).
  `br list --json` wraps rows as `{"issues":[…]}` — a bare `.[]` accessor reads
  EMPTY and looks like a clean absence.

## Measurement law

- **Every absence claim needs a positive control that FIRED, in the same
  instrument and the same run.** Presence of a control discharges nothing: if the
  control returns nothing, that is a broken instrument, not a result. A zero from
  a predicate that could not have matched is INVALID, never clean.
- **Check a predicate's REACH against the concept, not its spelling.** A true
  zero in the wrong library, or under the wrong term of art, produces confident
  wrong conclusions.
- **Drive the check red and read it.** Not "ask what a failing run would look
  like" — produce the failing state and look at the output. Asking is answerable
  honestly and wrongly: a build whose edit silently wrote nothing returned
  `163/163` and its agent read that as success. A check that has never been seen
  to fail has not been shown to discriminate.
- **A probe whose two arms AGREE has measured nothing** — and neither has a
  ONE-ARMED probe compared against a figure in a document. A finding that
  overturns a claim must **exhibit both arms**, from your own instrument, in one
  run. Exhibited, not necessarily executed: substituting a primary source for an
  arm is legitimate, asserting the arm is not. **The two arms must measure the
  same object** — two runs of a predicate broken the same way in both agree
  perfectly and have measured nothing.
- **A report about an artefact is never a measurement of it.** Re-derive; do not
  relay.
- **Your brief is a claim set, not ground.** Sampled across four independent
  strata, the dispatch carried a false load-bearing claim in 4/8, 4/8, 5/8 and
  8/8 of runs. Two distinct failures, and the second is the common one: the
  claim is **stale** (true once, since fixed), or the claim is **simply wrong
  about a live artefact** — a count, a path, a cause, a coordinate. Test the
  load-bearing ones before building on them. Confidence markers do not protect a
  claim: one brief's ★-marked "a bisect just established the cause" was the
  false part.
- **Coordinates drift, and "at HEAD" is not a coordinate.** Re-derive any cited
  line, digest or path before acting on it — and say *which copy* you read. A
  clone can run ahead of what the system actually resolves, so where a pin exists
  (`/nix/store`, a lock file, an explicit sha) read the pinned rev, not the
  working tree.

## Reporting

State what you **evaluated** versus what you **derived**, and never present a
derivation as a measurement. A partial result reported as partial is useful;
reported as complete it is worse than nothing.

**Three disclosures are owed, and each has something a reader can check.** (1)
**A premise of your brief that you falsified** — lead with it. (2) **A
measurement you re-ran because the first was broken** — give both runs and the
path of the retained probe, not a narration. (3) **Files you wrote through a
shell heredoc or script** rather than the edit tools — name them by path, since
they are invisible to any later reader of your trace.

★★★ **A NEGATIVE-CONTROL TOKEN IS GENERATED FRESH PER RUN AND NEVER WRITTEN DOWN.** A control token proves
your predicate is not dead by returning 0 — and the moment it is recorded in a spec, a report, a bead or a
prompt, **it is in the corpus**, so every later sweep quoting it gets a plausible NON-ZERO that reads
exactly like a live control firing. Measured twice in this project: `zzqqx` matches 65 files across
`specs/` and `reports/` because prior agents wrote their own token into the corpus, and its published
replacement `qqzzxwv` was burned by the act of naming it in the warning. **Naming a third would burn the
third.** ⇒ Generate it (`/dev/urandom`, a uuid fragment, `$RANDOM`), use it, and report the COUNT and the
METHOD — never the string. ★ And treat any sweep that quotes a LITERAL control token from a document as
suspect on sight: check whether that token is already in the corpus before believing its zero.
