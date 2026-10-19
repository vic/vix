---
description:
  "Runs an adversarial review loop: independent critics try to break an artifact
  and the author revises against surviving objections. Use at the spec-driven
  review gate, before marking a tasks.md phase done, or when asked to red-team a
  plan, spec, or design."
allowed-tools:
  Agent Read Grep Glob Bash(printenv:*) Bash(env:*) Bash(openspec:*)
---

Run an adversarial review: independent critics try to BREAK an artifact (plan,
spec, design, or code). The author revises against surviving objections, and the
loop repeats until nothing survives. This is the refutation loop, not a
politeness pass. The full methodology and its citations live in
`references/adversarial-review-methodology.md`, read it before running the loop
the first time.

## When to run

- At the spec-driven review gate: before a `tasks.md` phase is marked done. The
  findings go to the change's `review.md`, never into the design.
- When asked to "adversarially review", "try to break this plan", or "red-team
  this design".
- MUST NOT run as a same-instance self-review. An adversary MUST be a separate
  instance or a different model (see the reference: unaided self-correction
  degrades quality).

## Decide whether model critique adds value

FIRST, the recursion guard takes precedence: if your own instructions contain
the literal sentinel `ADVERSARIAL-CRITIC-ROLE`, you are already a critic. SKIP
this entire selection step and go straight to "Pick the execution path" path 1
(produce your objection and return). A critic never elicits and never runs the
gate.

The guard reads the prompt, not the environment. Do NOT use
`$CLAUDE_CODE_CHILD_SESSION` for this. It is set in top-level sessions too.
Verified on claude 2.1.220: the variable is present in the parent process
environment of an ordinary interactive session. So an environment-based guard
refuses to spawn critics in exactly the case that needs them. The sentinel is
written by this skill when it spawns a critic, so it is the only signal the
skill controls.

Otherwise, run the deterministic `specutil check` lint first. Model critique is
optional evidence. It is not an approval gate and is never required only because
a harness provides it.

1. Run `specutil check <change-dir>` first regardless (it is cheap and pure).
   Fix every violation before offering the loop.
2. Run the loop when the user requests it or when a concrete risk needs an
   independent model critique.
3. Otherwise, skip it and record
   `Adversarial review: not run; deterministic lint passed` in the phase
   checkbox.
4. In unattended runs, do not add model work unless the task or repository
   policy requests it.

`specutil check` must still pass. Human-verification gates for impactful actions
still apply. A critic result never represents owner or peer approval.

## Pick the execution path

Route on what the review needs, not on what the harness offers. Fresh context is
the point of the exercise, so the capability question is only a fallback.

1. Already a critic, your instructions carry the `ADVERSARIAL-CRITIC-ROLE`
   sentinel. You are a {{agent}} spawned for review. Do NOT spawn more critics
   (recursion guard). Produce your own objection and return.
2. Fresh-context {{agents}}: THE DEFAULT. A Task/Agent mechanism exists. Spawn N
   critic {{agents}}, one per lens, each with its own context.
3. Shared-context {{agents}}, use ONLY when a critic must observe live session
   state that is not on disk. That means an unsaved buffer, a running process,
   or a value that exists solely in this conversation. Name that reason in the
   round record. If the work is on disk, this path is wrong.
4. No {{agent}} capability, run N sequential critique passes, each in a fresh
   reasoning context with authorship hidden.

Prefer path 2 over path 3 for correctness, not cost. A critic that shares the
author's context inherits the author's reasoning. A critic that has read the
argument for why the code is right is measurably worse at finding the way it is
wrong. The strongest published result on this is the Bun Rust port. There the
reviewer "gets the diff and nothing else, none of the implementer's reasoning".
Context starvation is the mechanism that makes the review adversarial; sharing
context defeats it.

Under Claude Code this means the Agent tool with a read-only subagent type. Do
not use an in-process teammate unless path 3's condition genuinely holds.

When the capability is genuinely in question, check with a shell probe, e.g.
`printenv CLAUDECODE CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`. Note that `printenv`
prints nothing for an unset name rather than a blank line, so read each name
separately when the distinction matters.

## Tell the critic exactly which tree to read (MUST)

A critic that reads the wrong revision produces confident false positives. The
common trap is `git diff HEAD`, which is empty once the author commits. A critic
re-checking after a commit sees no change and reports the original defect as
unfixed. Observed in this repository: a critic re-raised a
character-substitution bug that was already fixed and committed. It cited
"`git diff HEAD` shows no edit to this line".

Every critic prompt MUST name the revision under review in one of these forms.
It MUST also tell the critic to read file contents, not a diff, when it needs
current state:

- working tree, uncommitted: "the work is STAGED; read `git diff --cached`"
- working tree, committed: "the work is in commits `<base>..<head>`; read
  `git diff <base>..<head>`, and read the file itself for current state"
- a re-check after revisions: "read the files directly; do NOT use
  `git diff HEAD`, the fixes are committed"

When a critic reports a defect as unfixed, the author MUST verify against the
file before acting. Re-fixing an already-fixed defect is how a loop churns.

Give the critic the call diff for the same revision when the change is not
Nix-only: `calldiff diff <base> --max-depth 3`. A line diff shows a critic which
lines moved. The call diff shows it which paths moved, and that is where a
defect of this kind lives. A path that appeared and is absent from the change's
own description is the objection to raise.

<examples>
<example>
<bad>Review the recent changes to the wezterm lua tree and find defects.</bad>
<good>ADVERSARIAL-CRITIC-ROLE: do not spawn further critics. The work is in commits `8edabbe86..HEAD`; read `git diff 8edabbe86..HEAD`, and read each file directly for current state. Use read-only tools only.</good>
</example>
<example>
<bad>Round 3 found nothing, so the change is approved.</bad>
<good>Round 3 returned NO SURVIVING OBJECTION from all 3 critics. Terminal state CLEAN. This is model evidence, not owner approval.</good>
</example>
</examples>

## Critics are read-only (MUST)

A critic MUST NOT modify the working tree. Spawn every critic with a read-only
{{agent}} type (`Explore` under Claude Code, or any type whose tool list
excludes Edit, Write, and NotebookEdit). Never spawn a critic as
`general-purpose`, because it holds the write tools. A critic that wants to test
whether a check fires will inject a defect to find out.

This is not hypothetical. A `general-purpose` critic reviewing a parse-check
phase injected syntax errors into two zsh files, to see whether the check caught
them. It left them in the tree, and they were committed under an unrelated
message.

If the harness cannot restrict tools, the critic prompt MUST state: "Use
read-only tools only. Do not edit, write, or revert any file. Report what you
would test and what you predict, and label it UNVERIFIED."

The author, never a critic, reverts any state a critic did create. Before
committing after a review round, diff the tree against the pre-review commit and
confirm every changed file is one you changed yourself.

## Deterministic rubric-lint first (`specutil check`)

Before spawning critics, run the deterministic half:
`specutil check <change-dir>` (installed on PATH). It checks only stated facts:

- design carries the required sections, and `Non-goals` is present.
- each `- Decision:` has an `- Alternative rejected:` marker.
- every phase declares a shape that the framework defines.
- a `loop` phase's `STOP` names a command, and a `graph` phase with more than
  one subtask declares a dependency.
- every task carries an `N.M` id belonging to its own phase, and every `deps:`
  reference resolves and forms no cycle.

Run `specutil check --list-rules` to see the resolved rubric. This part is a
pure function of the artifacts and is reproducible. The LLM refutation below is
stabilized but NOT bit-deterministic: two runs converge without being identical.
It pins the artifact snapshot, the rubric, N, and the lens set. It runs at
temperature 0 with a structured verdict and a majority vote. Do not claim more
than that. Fix every violation before the critic loop.

## The loop (summary: reference has the sourced detail)

1. Bind the rubric. For an OpenSpec change, the rubric is the proposal's
   `Behavior` criteria and `Non-goals`, plus the design `Decisions` and
   `Rollout & Gating`. A critic MUST cite the rubric item it believes is
   violated.
2. Spawn N=3 independent critics, authorship hidden, one lens each (rotate
   across rounds: correctness, security, ops/rollback, cost, data-migration,
   citation). The `citation` lens adjudicates whether a pinned quote supports
   its claim, as SUPPORTS, CONTRADICTS, or UNRELATED over the snapshot. It MAY
   run only after the `citelock` offline gate (Tier 0) is green for the change.
   Every critic prompt MUST open with the literal line
   `ADVERSARIAL-CRITIC-ROLE: do not spawn further critics.` That sentinel is
   what the recursion guard reads. Omitting it lets a critic that loads this
   skill spawn its own critics. Each critic contract: "Produce a concrete
   scenario in which this artifact fails. Name the violated rubric item. If you
   cannot, reply `NO SURVIVING OBJECTION`."
3. Keep only objections with a concrete failing scenario, reproducible
   conditions or an isolated verification question. Reject prose-only comments.
4. Revise the artifact against surviving objections only. The author revises. A
   critic never both blesses and rewrites unaided.
5. Repeat.

## The loop is a state machine; run it as one

Do not run this as an implicit "repeat until it feels done". The loop has named
states, one transition per condition, and six terminal states. Declare which
state you are in at each step, and name the terminal state you reached.

```
                ┌──────────┐
                │   LINT   │  specutil check (mandatory, deterministic)
                └────┬─────┘
              fail ← │ → pass
                ┌────┴─────┐
      REVISE ←──┤  SELECT  │  run only when requested or risk-justified
                └────┬─────┘
            not run ←│→ run
                     │        └──────────────→ [NOT_RUN]
                ┌────▼─────┐
           ┌───▶│  ROUND   │  spawn N critics, one lens each
           │    └────┬─────┘
           │         │ count surviving objections
           │    ┌────┴──────────────────────────────┐
           │    │ count == 0            → [CLEAN]   │
           │    │ owner says stop       → [HALTED]  │
           │    │ round == K            → [CAPPED]  │
           │    │ no decline in 2 rounds→ [STALLED] │
           │    │ all fix-induced       → [CHURNING]│
           │    │ otherwise             → REVISE    │
           │    └────┬──────────────────────────────┘
           │    ┌────▼─────┐
           └────┤  REVISE  │  author fixes surviving objections only
                └──────────┘
```

Terminal states: `CLEAN` means no critic objection survived. It is not approval.
`NOT_RUN` means no model critique was requested or justified. `HALTED` is an
owner decision made during a loop. `CAPPED`, `STALLED`, and `CHURNING` all hand
back with open objections and MUST be reported as such, never as a pass.

### Elicit at every round boundary, do not wait to be stopped

The owner should never have to interrupt to end the loop. At the end of every
round that does not reach a terminal state, ASK whether to continue before
spawning the next round. Use the interactive prompt (AskUserQuestion under
Claude Code). Do not start round N+1 silently.

The question MUST carry the decision inputs, because "continue?" with no data is
not a question the owner can answer:

- the round just finished and the cap for this blast radius
- the surviving-objection count for every round so far, as a trend
- a one-line summary of each objection fixed this round
- whether anything remains open

Offer three options, with the recommendation first:

1. Continue to round N+1. Recommend this while the count is still declining and
   the cap is not reached.
2. Halt and go to the gate. Recommend this when the count is flat or rising,
   when the round produced only fix-induced regressions, or when the remaining
   objections are cosmetic.
3. Halt and drop the open objections, recording them as accepted.

Recommend option 2 explicitly when a stop-early condition is close, rather than
burning the round and reporting it afterward. The owner's time is the scarce
resource, not the round budget.

### Escape hatch: the owner may halt the loop at any point

The owner can stop the loop mid-flight and go straight to the gate. Honor it
immediately, at the next transition, without starting another round and without
finishing an in-flight revision that no objection requires.

Recognize any of: "stop the review", "skip the rest", "go to the gate", "ship
it", "enough rounds", or an explicit `HALT`.

On halt:

1. Stop spawning critics. Do not start round N+1.
2. Apply nothing further. Objections already surfaced but not yet fixed stay
   open; do not silently drop them.
3. Report terminal state `HALTED`, the round reached, and every open objection
   with its failing scenario. The owner then chooses with the whole list in
   front of them.
4. Record the halt in the phase's review checkbox as
   `Adversarial review: halted by owner at round <n>, <m> open`.

A halt is not a pass. `specutil check` still runs, and the human-verification
gate for impactful actions still applies.

### Drive the iteration with `/loop` when it is available

When the `loop` skill is available, drive ROUND→REVISE→ROUND with `/loop` and no
interval. The model then self-paces one iteration per round, and the loop's own
stop call is explicit. End it with the loop's stop control the moment a terminal
state is reached. Without `/loop`, run the transitions inline, but still
announce the state each round.

## Stop

- STOP on success when a full round returns `NO SURVIVING OBJECTION` from all N
  critics. This is the only clean terminal state.
- An objection "survives" a round if a majority of critics uphold it on
  re-examination.

### Round cap, scaled to blast radius

The cap is not a constant. Size it to what is under review, then stop:

| Under review                                                                 | K   |
| ---------------------------------------------------------------------------- | --- |
| One file, or one phase of one capability                                     | 2   |
| One change, one capability                                                   | 4   |
| One change spanning capabilities, or any change that mutates the live system | 6   |

### Stop early on thrash

More rounds only help while the loop is converging. Track the surviving-
objection count per round and stop before K when either holds:

- The count fails to decline across two consecutive rounds. The loop is not
  converging and another round is unlikely to change that.
- Every surviving objection in a round was caused by the previous round's own
  fixes. Fix-induced regressions mean the artifact is churning, not improving.

Both are hand-back conditions, not failures. Report the trend and let the owner
decide whether to continue, re-scope, or accept the open objections.

## Output

Report, in order:

1. The rubric bound.
2. The surviving-objection count per round.
3. Each round's surviving objections with their failing scenarios.
4. The revisions applied.
5. The terminal state.

The terminal state is one of:

- `no surviving objection`
- `not run`
- `halted by owner at round <n> with <m> open`
- `hit K=<n> with <m> open objections`
- `stopped on non-convergence after <n> rounds`
- `stopped on fix-induced churn after <n> rounds`

Do not pad a clean result with invented objections, a critic that finds nothing
MUST say so. Do not report a cap hit as if it were a clean pass. An artifact
that never reached a clean round has known-unreviewed state, and the report MUST
say so plainly.

Even a clean critic round is model evidence only. Never write an owner approval
or peer-review decision from this result.
