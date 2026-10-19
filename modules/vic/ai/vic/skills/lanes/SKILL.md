---
name: lanes
description: Never-stall parallelism law (ALL projects) — TIME = binding constraint. Keep 7 lanes saturated: build, verify, soundness, recon, plan, hygiene, measure. Use at every dispatch decision and whenever WAITING on anything.
---

# LANES LAW (vic, global) CVMN — supervisor waiting on one agent w/ empty lanes = time crime.

## NESTING TRUTH
Subagents CANNOT spawn subagents. 1 level: supervisor → workers. Bigger fan-out = Workflow tool. Worker needing delegation = partition error — re-split at supervisor.

## THE 7 LANES (coding = ONE of seven)
BUILD (vic-rung/typesmith) · VERIFY (vic-reviewer+probe on LAST deliverable while next builds) · SOUNDNESS (vic-lawyer audits in parallel; blocks LAND not BUILD) · RECON (vic-reader/sweep PREFETCH next task's inputs during current) · PLAN (vic-planner drafts next spec skeleton) · HYGIENE (vic-scribe: HANDOFF/state/tracks/playbooks/telemetry — always-on) · MEASURE (vic-probe benches, disjoint from BUILD's deps only).

## SATURATION PROTOCOL
1. Dispatch primary → IMMEDIATELY spawn RECON+PLAN for 1-2 tasks AHEAD (same message, parallel calls / background).
2. Deliverable lands → VERIFY lane on it; do NOT wait — start next BUILD (verify-fail = revert one rung, cheap).
3. Never block on one TaskOutput w/ empty lanes — fill first, then collect.
4. Session-end minutes: HYGIENE runs WHILE final answer composes (scribe gets facts early).

## COLLISION LAW
BUILD lanes = disjoint dep lanes ONLY (agent on crate X locks X's deps; map deps b4 dispatch; core/shared lib = solo lane). Never bench a crate being edited. NO commit while agents in flight. Caps: haiku ≤15 · sonnet 3-4 · opus 2-3 · derive 1.

## ANTI-STALL SELF-AUDIT (each turn)
Waiting >60s + empty lanes? → fill RECON/PLAN/HYGIENE. Reading big file while agents idle? → that's a reader lane. Writing long spec while nothing runs? → dispatch the census/probes the spec needs FIRST, write while they run.
