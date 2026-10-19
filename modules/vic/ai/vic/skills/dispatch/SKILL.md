---
name: dispatch
description: Model×effort dispatch law (ALL projects). Use BEFORE spawning any Agent/subagent or fleet, and when deciding which model/effort tier a task warrants. Triggers — delegate, parallelize, fan-out, "which model", cheap-vs-expensive, agent burn, subagent spec. Do NOT use for work you'll do inline yourself, or for HOW to implement a task (that's the task's own skills). Wrong model×effort burns money both ways — load the skill for the tier table, spec skeleton, partition rule, lanes, and dispatch gates before you spawn.
---

# DISPATCH LAW (vic, global) CVMN

## LABEL LAW (visibility @ Claude Code UI — EVERY spawn, no exception)
Agent-tool `description` + Workflow `label` MUST start `<model>/<effort>:` — exactly one of `haiku/low:` `sonnet/med:` `opus/high:` `fable/xhigh:` — then 3-5 word task. Ex: `description: "haiku/low: gate census 61t"` · `label: "haiku/low:u3a1"`. Spawn w/o tier-prefix = re-dispatch. Purpose: vic reads burn at a glance in the task tree; telemetry rows match labels.

## TIERS — pick EXPLICIT model every dispatch, never default-inherit (inherit = priciest)
| tier | agents | use | conc |
|---|---|---|---|
| haiku-low | vic-probe/reader/sweep/scribe | instructions ARE the thinking: run-exact, extract, tally, doc upkeep | ≤15 |
| sonnet-med | vic-rung/isolate/reviewer/planner | tight spec + objective oracle, LOCAL decisions only (MOST dispatches) | 3-4 |
| opus-high | vic-hunter/typesmith/lawyer/perf | global constraints juggled, multi-constraint debug, judgment recon | 2-3 |
| xhigh | vic-derive (fable main-thread while alive; retires ~2026-06-17) | derivation/proof-grade, law-underspec, soundness surgery | 1 |

BURN: fable ≈2× opus ≈4× sonnet ≈8× haiku. Models: haiku 4.5 · sonnet 4.6 · opus 4.8 · fable 5. Effort = session-level; per-dispatch control = model + prompt depth ("answer directly" vs "think hard, derive") — STATE which in every spec.
MIS-PAIRING RECEIPTS: haiku-xhigh = drift loops · fable-low = genius copy-paste · opus w/o minrepro = 10× burn · sonnet on underspec = plausible-wrong reverted.

## PARTITION B4 TIER-PICK
1 opus task usually = 1 supervisor design + 3 haiku/sonnet pieces. Tighter spec ⟹ cheaper tier. Playbook'd class (/playbook) ⟹ drop one tier. Unsure ⟹ sonnet-med. Design NEVER below opus; vic-gates (deps/encoding/scope/commit) never delegated.
WORKSPACE GATE (/workspace): repo-editing dispatch ⟹ `vic-ws new` FIRST, path in spec, agent forbidden jj/git; supervisor lands linear (vic-ws land) / drops losers. SWARM (/superhaiku): ≥3 checkable units ⟹ compile→isolate→k×vic-superhaiku→vic-judge→land.
ENSEMBLE DOWNGRADE (/ensemble): output mechanically checkable ⟹ k×haiku (vic-chain) + vic-judge filter REPLACES sonnet/opus — 5×haiku ≈ 0.6×sonnet. Checklist-compiled chains (vic-planner CHECKLIST MODE → vic-chain) = haiku executes what only sonnet+ survived before. Verify ≈ generate (proof/design) ⟹ NO ensemble, real tier.

## SPEC SKELETON (every dispatch ≥sonnet; missing piece = agent SPEC-GAPs back)
SCOPE exact + NOT-SCOPE · ORACLE (runnable failing test) + NEG CONTROL (mutant must REJECT) · LAW cite + quote (vic-law) · PRE-DEBUNKED dead leads w/ kill receipts · EVIDENCE demanded (pastes per checkpoint; report file appended per step) · HONESTY (numbers verbatim if slower/negative; honest negative = success) · BUDGET (n attempts; 3 fails ⟹ stop + /escalate note).

## LIFECYCLE
Parallel = disjoint dep lanes only (agent on crate X locks X's deps; run-only agents lock nothing). NO commit while agents in flight. Agent death ≠ work lost: check disk b4 re-dispatch. Background = max drift → gated checkpoints. VERIFY-DON'T-TRUST: every deliverable → vic-reviewer (code) / vic-lawyer (law-touching) / own x-check. NEVER STALL: saturate lanes per /lanes; subagents can't nest — supervisor = only spawner; fan-out = Workflow.

## TOKEN DISCIPLINE
Thinkers never run cmds (vic-probe), never bulk-read (vic-reader), never explore inline (codegraph first). RECALL-B4-RUN: `vic-recall '<pat>'` b4 expensive cmds; `vic-mine` b4 re-solving (/ledger). TELEMETRY DUTY: after EVERY dispatch `vic-telemetry add <agent> <model> <tier> <secs> <tokens> <outcome>`; `report` = routing feedback; this table = LIVING policy (scribe edits w/ receipts).
