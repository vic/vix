---
name: superhaiku
description: THE haiku-fleet composition (ALL projects) — compile→isolate→swarm→judge→land pipeline that lets a haiku fleet outperform fable on THROUGHPUT and COVERAGE of mechanically-checkable work. Use when a task decomposes into ≥3 checkable units, or when burning sonnet/opus/fable on execution-shaped work.
---

# SUPERHAIKU (vic, global) CVMN — fleet beats genius WHERE WRONGNESS IS CHECKABLE. 0 EXCEPTION on the valves.

## HONEST CLAIM (route by this, not hype)
Fleet SURPASSES fable on: units/hour (10+ vs ~2), corpus coverage, cost/accepted-unit (~1/10), drift-immunity (units too small to drift). Fable keeps: derivation, design, law interpretation, root-cause verdicts. Pipeline VALVE escalates exactly those — superhaiku makes the expensive models do ONLY what only they can do. That division IS surpassing.

## PIPELINE (5 stages, fixed)
1. **COMPILE** (supervisor or vic-planner CHECKLIST MODE — intelligence spent ONCE): task → DAG of micro-units, each: scope ≤2 files · checklist steps w/ CHECK+EXPECT · ORACLE (runnable) + NEG control · dep edges. Unit not checkable ⟹ it stays OUT of the swarm (high-tier lane).
2. **ISOLATE** (/workspace): `vic-ws new u<N>a<k>` per attempt — k workspaces per unit for k-shot.
3. **SWARM**: k×vic-superhaiku per unit, ALL parallel across independent DAG nodes (≤15). Prompt ≤2K tokens: unit spec + workspace path + attempt-index k (vary approach hint by k).
4. **JUDGE**: vic-judge runs unit ORACLE on each attempt's workspace → first passer per unit. 0 passers after k → ONE recompile of THAT unit (tighter spec) → still 0 ⟹ VALVE: unit escalates one tier w/ all failures attached. NEVER round 3 at haiku.
5. **LAND** (supervisor only): winners `vic-ws land` in DAG order + losers `vic-ws drop` → full-suite vic-probe after each land (green-tree) → vic-reviewer on the landed sum → telemetry both per-unit and pipeline totals.

## WORKFLOW TEMPLATE (ultracode; adapt UNITS)
```js
const UNITS = args.units // [{id, spec, oracle, deps, ws:[paths]}] — compiled + workspaces pre-made by supervisor
const done = {}
async function run(u){
  for (const d of u.deps) if(!done[d]) throw new Error('dep order')
  const tries = await parallel(u.ws.map((w,k)=>()=>agent(
    `${u.spec}\nWORKSPACE: ${w} — all edits inside; jj/git FORBIDDEN.\nATTEMPT ${k}: ${k>0?'use a DIFFERENT implementation shape than the obvious one':''}`,
    {agentType:'vic-superhaiku', model:'haiku', label:`haiku/low:u${u.id}a${k}`})))
  const verdict = await agent(`Judge per oracle:\n${u.oracle}\nCandidates (workspaces): ${u.ws.join(' ')}\nPICK: first passer`,
    {agentType:'vic-judge', model:'haiku', label:`haiku/low:judge-u${u.id}`})
  done[u.id] = verdict; return verdict
}
// topological loop over UNITS calling run(); return {verdicts: done}
// LANDING happens AFTER workflow returns — supervisor runs vic-ws land/drop per verdict.
```

## VALVES (hard, non-negotiable)
unit fails 2 compiled rounds → tier up w/ receipts · judge says NOT-MECHANICAL → tier up · land conflict → partition error, drop + re-compile DAG · suite breaks post-land → revert that land FIRST, then diagnose · telemetry must show cost/accepted-unit < solo-tier cost or pattern reverts for that class.
