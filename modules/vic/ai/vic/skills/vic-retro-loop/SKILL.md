---
name: vic-retro-loop
description: Retrospective + learning loop for agent work (ALL projects). Use at the end of every PM wave, at session end, after an agent was rejected/killed twice, or when Vic asks "what did we learn" / "optimize the workflow". Measures burn vs quality, dispatches vic-retro to diagnose and propose prompt/skill/tier changes, and records learnings in the vix repo so they survive hardware moves.
---

# retro — measure, learn, optimize (quality never drops)

Rule: a change ships only if quality holds (oracle + reviewer still pass) AND time or tokens drop. Faster-but-worse = rejected.

## When
- End of every PM wave (mandatory). Session end. Same failure twice. Vic asks.

## Loop
```
2. retro   dispatch vic-retro (opus/high)    (measure, diagnose, ≤5 proposals, beads class:retro)
3. judge   PM reads proposals; Vic rules on any skill/agent/tier change (no silent policy edits)
4. apply   accepted proposal -> vic-rung/vic-scribe edits in a jj workspace; bead stays open
5. prove   next wave: compare the named metric before/after; close bead w/ numbers, or revert
6. learn   vic-retro appends verified lessons: vic-pm learn <file> "<lesson>" (skill vic-lessons, append-only, auto in every agent)
7. record  vic-scribe: notes/retro-*.md + quipu episode ledger:<proj>/retro/<date> (edges: `retro → proposes → bead`, `proposal → targets → skill file`; read-back `quipu_ask references_to` on the bead IRI) + export to pm/quipu/
```

## What to measure (per class × tier)
- tok/run, secs/run, est-err (actual vs estimate), fail% (reject+killed+specgap), rework count.
- Quality guards: first-run accept rate, reviewer 🔴 count, reverted landings. These must not get worse.
- Cost: `ccusage session --json` (`modelBreakdowns` per model) and `ccusage blocks --active`; tier mix vs cost per wave.
- Sources: `vic-telemetry classes` and `vic-telemetry report` (quipu graph, group_id telemetry; the SubagentStop hook writes each stop there), `vic-telemetry votes <sprint>` (scrum votes, group_id scrum), `omni_health`, `omni_recall`. Never read or append telemetry files.
- Hook rows have `failed = 1` even when the outcome is `done`, so `fail%` from `vic-telemetry classes` is wrong for them. Count failures from `a:outcome`. Recipe and cause: skill `pm`, §2 ESTIMATE, "Telemetry trap".

## Learn from the past with quipu (reads that work: skill `vic`, "QUIPU STORE = WHAT WORKS")
- What did we believe when it failed? Run the root-cause query with `tx: <n>` (or `valid_at`) at the failing wave, then without it. The difference is what we learned since. A lesson that was recorded before the failure is a reading failure, not a knowledge gap: the fix goes into the brief or hook, not into a new lesson.
- Was it already known? `quipu_query` on label prefix `ledger:<proj>/mistake/` and `ledger:<proj>/evidence/`, plus the operating-memory recipe on the failure word. Same mistake twice = the record exists but nobody read it.
- Which knowledge is central or isolated? `quipu_report` (hubs, bridges). `quipu_ask references_to` on a ledger IRI. A mistake with no incoming edge cannot be found from the bead or file it was about.
- Before a proposal supersedes a recorded rule: `quipu_impact` with `remove: true` on the rule IRI shows what depends on it. The store does not change.
- Every recorded lesson carries evidence (cmd + output + control) and edges to its bead, file and agent. Pre-check the turtle with `quipu_validate` and a shape that requires those, since no shapes are loaded in the store.

## Proven levers (Anthropic research + vic measured history)
- Prompt quality beats model upgrade: a failing class gets a tighter spec FIRST, tier bump SECOND.
- Delegation prompt = objective · output format · tools/sources · scope limits · effort budget (tool calls).
- Effort scaling: fact-find 1 agent / 3-10 calls · compare 2-4 agents / 10-15 calls each · complex 10+ agents w/ disjoint scope.
- Subagents return ≤2k-token summaries; bulk output goes to files, PM gets paths.
- Fresh-context reviewer (writer ≠ grader). Reviewer flags correctness/requirement gaps only; style findings are optional.
- Two failed corrections in one context = restart fresh w/ a better prompt, not a third try.
- Deterministic duties (logging, gates) belong in hooks, not in prompts.
- Failure + its prompt given to Claude = it can diagnose and rewrite the prompt (vic-retro does this).

## Persistence
Telemetry and scrum feedback live in the global quipu graph, not in files. Everything else learned lands under `modules/vic/ai/vic/pm/` (git-tracked): `notes/retro-*.md`, beads `class:retro`, `quipu/`, `omni/`. Chat-only or ~/.claude-only learning = lost.
