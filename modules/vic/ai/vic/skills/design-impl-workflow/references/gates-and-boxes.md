# Gates and boxes (generic checklists)

Run the BRIEF GATE for every brief, before writing and again before sending. Run the RULE-FAMILY BOX for every
brief that loads, extracts for or changes a normative rule family, and for every fix to a normative program.

## BRIEF GATE

Re-read: the workflow notes, the live discipline and lessons, the queue, the phase plan, and the spec sections the
task touches (rules and examples). Then check each line.

- [ ] On the critical path to the goal, or a queue item attached here; no throw-away work.
- [ ] Wired into the product path, or names the task that wires it.
- [ ] No duplicate of an existing producer (one loader, one walker, one growth helper). A copy found in a report
      becomes a queued dedupe on the next brief that touches it.
- [ ] Spec lines cited. Gaps ruled in the rulings file, not guessed.
- [ ] Every expected value measured on current code with a probe. Headers compile on two compilers.
- [ ] Every name ruled. Fixture unit-index table complete. Changed expectations listed.
- [ ] Mutants compile, change the checked value, one exact predicted outcome with named failing checks.
- [ ] Every mutant `before` text read in the real file, exactly one match.
- [ ] Every fixture text parsed with the parser probe. Edits anchored by text, not line numbers.
- [ ] Design wrote no implementation bodies, so mutant counts on new code are marked predicted.
- [ ] Fits one 10-minute agent run. Model and effort named. Self-contained (the implementer sees no design docs).
- [ ] Queue items that ride on this phase are included.
- [ ] Tracker: bead exists (epic, blocks edges, weight label, planned length); the brief has a PERF section with a
      separate agent, baselines from the last landed rows, bar stated before the build.
- [ ] A new surface feature queues the self-use task.
- [ ] No unfilled placeholder in the staged copy.
- [ ] Every binary a command runs is made by a step in the brief.
- [ ] Hot-phase briefs carry a perf step with a wide input.
- [ ] A changed expected value (test or golden) has a ruling with an independent derivation. A gate miss blocks.
- [ ] Haiku-tier code agents get the line: run every build in the foreground, one at a time, never in background.
- [ ] Every cited ruling was opened and compared with each step (three briefs contradicted their own ruling).
- [ ] FILES line agrees with the expected diff-stat line.
- [ ] No "no existing X" claim without the search command, its zero output and an armed control.
- [ ] Complexity stated for every new loop or lookup.

## FAILURE-PATTERN BOX (one line each in every brief's notes)

- A1: can it accept a program without evidence about the value? Is there a catch-all arm?
- A2: a flag or relation another phase must read: is that reader in the brief?
- A5: found by name instead of by id or graph link?
- A6: does it decide a user-level error in host code instead of emitting facts for a rule? Interim typed failures
  only fail closed and are listed for conversion.
- A9: a spec "is rejected" touched: code, rule AND negative test all present?
- B2: every mutant reads the checked value?
- B2': a new obligation lands with the rule that rejects its cheap workaround (idle or vacuous facts).
- D1/D3: per-item lookups indexed? Stack bounded?
- C5: every new lookup or loop states its complexity and the spec bar it meets.
- Lanes share no scratch output, cache or verdict file; each lane has its own workspace and build directory;
  perf-log rows are merged by design at landing.
- Every mutant: ONE exact predicted outcome and the named checks that fail.
- Hot-phase briefs carry a perf step with a wide input.
- No sentinel; typed outcome with kind and payload.
- E: a stage-1 or second-implementation agreement is stated where a verdict is added.

## RULE-FAMILY BOX

- [ ] Before the family brief: every "owes / is rejected" sentence of the spec section has a minimal REJECT fixture
      (the smallest fact shape that must fire) plus an ARMED control (same shape with the clearing piece added
      accepts). Run both on the engine and paste both lines.
- [ ] An obligation is keyed on the structure that creates the duty, never on the presence of the evidence that
      clears it.
- [ ] Every filter that drops a kind cites the exact spec sentence that exempts it, and the exemption is no wider
      than the sentence (an exemption for "tail self calls" must not drop all tail calls).
- [ ] Every key or cache hashes every input whose change can change the verdict, callee contracts included.
- [ ] A passing accept fixture that passes because the rule never fires is a bug. Each accept fixture states the
      obligation it clears and the fact that clears it.
- [ ] Interim gaps (a family not yet extracted) are listed in the brief and visible in the reply.
- [ ] Normative table key uniqueness checked.
- [ ] Functional tables (one value per key) have a right-uniqueness rule. A contradictory entry scope must not
      derive an empty interval that vacuously clears an obligation.

## ACCEPTANCE CHECK (design lead, per lane)

- [ ] Report read; each drift ruled in one line.
- [ ] Rebuilt from clean; unit tests green on every compiler and the sanitizer build; project and golden checks
      green; hash of staged headers matches; diff-stat equals the FILES line.
- [ ] Code read against the contract. Names are full words. No dead code. No second producer.
- [ ] RED run was pasted (accept a missing red only if the mutants prove the checks discriminate).
- [ ] Mutants: each FAIL as predicted, restore proved byte-identical. Drift in counts is ruled.
- [ ] Commit, then perf rows tagged with the commit, gated against the previous row.
- [ ] Tracker reports per stage; docs updated; docs committed; next brief sent.
- [ ] Auditor notified with commit hash, task id, bead and brief path.

## LANDING CHECK

- [ ] `jj st` shows no foreign change. No agent in flight in this working copy.
- [ ] Rebase onto the tip (linear). No merge commit. `divergent()` is empty.
- [ ] After rebase: LAND-VERIFY on the new tip (build, tests, checks) by a small agent; lead reads the pasted lines.
- [ ] Workspace removed after landing. Perf baselines refreshed if several lanes landed in a row.
- [ ] Never move the main working copy over the implementer's uncommitted note edits.
