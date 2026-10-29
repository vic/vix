---
description:
  Runs a two-agent loop for fast, safe iteration on a codebase. A supervisor
  (you) designs, specifies, reviews and jj commits; one long-lived haiku/low
  "coder" teammate makes every edit, one small task at a time. Use when /vic
  asks for many features, fixes or UX changes in a row and wants them landed
  quickly with green tests and one commit each. Do not use for open-ended
  research, for design that Vic has not approved, or for a single small edit
  you can make yourself.
---

# compa

You are the supervisor. A cheap coder agent writes all the code. You turn each
request into a task small enough that the coder cannot get it wrong, you check
the result, and you commit it. This loop shipped 120+ tasks in one session.

Required skill `/vic` `/pm`. This is a lighter version of `/mob` with only two
members.

## Roles

| Who | Does | Never does |
|---|---|---|
| Supervisor (you) | Reads code, writes specs, reviews diffs, runs the full suite, commits with jj, keeps the tracker and the handoff | Edits product code (Vic: "only coder will edit") |
| Coder (haiku, low effort) | Edits the files the spec names, runs the checks the spec names, reports | Runs git or jj, runs python, edits files outside the spec, decides design |

Start the coder once and keep it:

```
Agent(name: "haiku-low-coder", model: "haiku", effort: "low",
      description: "haiku/low: idle coder for <repo>",
      prompt: "You are coder ... Reply 'coder ready' and stop. Wait for tasks via SendMessage.")
```

Then send every task with `SendMessage(to: "haiku-low-coder")`. A stopped coder
resumes on the next message, with its history.

## The loop

1. **Track.** Put every request into the tracker first (`br create`; beads in
   `.beads`). One bead per feature or bug, with priority. Vic asks "status" often:
   answer from `br list --status open` and `--status deferred`.
2. **Read before you spec.** Find the exact functions, line numbers and API
   names (`rg -n`, `sed -n`). Check library signatures in the module cache
   (`~/go/pkg/mod/...`) before you name them. A wrong file name or API in a
   spec costs a full round trip.
3. **Write one small task.** See "Spec rules".
4. **Send it, then wait.** Do not send the next task until this one is
   committed. A queued task gets built early, before your commit, and lands in
   the wrong commit.
5. **Review the report.** Check what changed against the spec. Read the diff
   (`jj diff --git`) for anything risky. A report is a claim, not proof.
6. **Verify yourself.** Run gofmt, vet and the full suite (and the build when
   main changed) before every commit, even when the coder reported green.
7. **Commit.** `jj commit -m "<STE message>"`, one commit per task. Close the
   bead. Append one line to `vic/HANDOFF.md`.
8. **Tell Vic.** Short: what landed, what it does for the user, what is next,
   any limit or decision. Then send the next task.

## Spec rules (what makes haiku succeed)

- **PIE order (`/pie`).** Open each task with P (goal and why), then I (files, output, oracle), and name the coder (E) last. Do not change the user-facing contract unasked.

- **One concern per task.** Split big work into steps that each end green:
  data/storage, then backend, then UI, then key bindings. A step adds a thing
  standalone with tests; the next step wires it in.
- **Name the files.** "Edit ONLY a.go, b.go, c_test.go." The coder stops when a
  fix needs a file outside the list: that is correct, approve it explicitly.
- **Give the code.** Paste the function bodies, struct fields, SQL and test
  cases. Haiku copies well and designs badly.
- **Give the oracle.** Exact test names, inputs and expected outputs, plus a
  negative case (bad input gives an error, unknown ID does nothing).
- **Give the checks.** Every task ends with: `gofmt -l`, `go vet ./...`, the
  full test suite, and for perf work a benchmark before and after.
- **Say when to stop.** "If a test fails, STOP and report the exact output; do
  not edit tests." "If X is already bound, STOP and report."
- **Warn about traps you know.** Pointer-receiver methods on a value from a
  getter (`m.Current().Lines.All()` does not compile; assign first). Locks held
  by a caller (`messageText` runs under `r.mu`: do not lock inside it).
  Positional struct literals break when you add a field.
- **End with:** "Report verbatim + files, then STOP and wait. No git/jj, no
  python."

## Review rules

- **Run the suite yourself before every commit.** The coder's green is not
  enough; it also catches edits made after its run.
- **Read stops carefully.** When the coder stops on a failing old test, decide:
  the test asserted old behaviour (approve updating only that expectation), or
  the change is wrong (fix the spec). Never let it weaken a test to pass.
- **Watch for scope creep and deviations.** The coder reports deviations; judge
  each one. Accept good ones (it found real bugs: a picker title array that
  panicked, a mention list that broke an old test).
- **Late duplicate reports are normal.** After each task the coder often sends
  a "re-verified, no edits" report. Answer with the next task or "already
  committed", nothing more.
- **Check the working copy before a commit** (`jj st`). Abandon an empty commit
  and redescribe if two tasks landed in one.

## Guards that paid off

- Add a test that walks every case of a growing enum or table (render every
  picker kind, every menu) so a new entry cannot crash at runtime.
- Add a test that enforces product rules Vic states ("every command is in a
  which-key menu", "every NORMAL key is in a menu").
- Keep golden render tests: they prove a refactor kept the look (the palette
  refactor kept today's colors because of them).

## Safety

- **Live accounts are read-only.** Never send, react, receipt or join on Vic's
  real account. Features that write are tested on a mock server or a local
  homeserver.
- **Secrets.** Never print, store or put a key in code. If the permission
  classifier blocks reading a secret, do not work around it: give Vic the exact
  command to run with `!`.
- **Destructive changes.** Large deletions (removing a whole subsystem) go in
  stages, each green. If a stage cascades (dozens of call sites), stop and ask
  Vic; he may defer it. To discard a half-done task: stop the coder first, check
  `jj st`, then `jj restore`.

## Mistakes we made (do not repeat)

- Naming the wrong file in a spec (the coder stopped twice for it). Check with
  `rg -n "func Name"` first.
- Sending the next task before committing: two tasks landed in one commit.
- A spec that hard-coded an early break on unsorted data. Ask whether the data
  is ordered.
- A test spec that did not compile. Compile-check tricky test code in your head
  or keep it simple.
- A fixed "press j 99 times" test broke when the help grew. Loop until the state
  stops changing.
- Changing the default look by accident. When restyling, keep a golden test and
  an explicit default palette.
- Letting the coder write a scratch file over an existing test. Say "create if
  missing; if it exists, append".
- The coder ran `python3` as a probe. Repeat "no python" in every spec.

## Talking to Vic

- Short replies. Answer first. One line per landed task.
- Ask only real decisions (a redesign, a deletion, a default that changes what
  users see, a new dependency). Give a recommendation, not a menu.
- When Vic gives a priority, reorder the tracker at once and say what moved.
- Before your context fills: update `vic/HANDOFF.md` (≤25 lines: done, doing,
  next command, open questions, rules) and `vic/state.md`, so a fresh session
  resumes from them.
- Always give summary of bead tasks and progress, doing, those planned and deferred.
