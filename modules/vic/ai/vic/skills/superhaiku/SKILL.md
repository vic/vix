---
name: superhaiku
description: Haiku-fleet DAG pipeline (ALL projects) — COMPILE -> ARM-ORACLE -> ISOLATE -> SWARM -> JUDGE -> LAND so a haiku fleet beats expensive models on throughput and coverage of mechanically checkable work. Use when a task decomposes into >= 3 checkable units.
---

# SUPERHAIKU PIPELINE (vic, global) — fleet beats genius where wrongness is checkable

**Stack:** `/vic-stack` (recall `quipu` before `COMPILE`; save landed evidence) · `/pie` (`P -> I -> E`) · `/jj` & `/workspace` (isolated workspaces + linear landing) · `/oracle` (armed baseline RED before swarming) · `/ensemble` (k-shot & ROI math).

**Assets in this skill:**
- `references/unit-spec-schema.md` — exact `<= 2K`-token unit spec schema, `agent-tier-gate.sh`-compliant spawn pattern (for both `Agent` tool fan-out and Python `run_workflow` / JS workflow runners), and `vic-judge` prompt.
- `scripts/ws-fanout.sh` — creates `u<N>a<k>` `jj` workspaces in one shot, **verifies the baseline oracle FAILS RED BEFORE spawning workers**, and cleans up all attempt workspaces after landing.

---

## 1. Fixed 6-Stage Pipeline (0 exception on valves)

1. **COMPILE (intelligence spent ONCE — lead or `vic-planner`):**
   - Decompose goal into a DAG of micro-units (`P` goal -> `I` output shape + runnable oracle + mutant -> `E` `haiku/low`).
   - Each unit: `<= 2` files, `<= 5 min`, `<= 2K`-token spec, exact checklist (`CMD` + `CHECK` + `EXPECT`), explicit `deps`.
   - Any unit whose correctness is NOT mechanically checkable stays **OUT** of the swarm (route to `sonnet/med` or `opus/high`).
2. **ARM-ORACLE (mandatory before swarming):**
   - Run every unit's oracle against the clean base commit via `scripts/ws-fanout.sh --check-red`. It MUST FAIL RED! (An unarmed oracle that already passes makes attempt 0 win falsely.)
3. **ISOLATE (`/workspace`, `/jj`):**
   - `scripts/ws-fanout.sh create --repo . --unit u1 --k 3 --rev @-` creates isolated `jj` workspaces `u1a0..u1a2` under `${XDG_RUNTIME_DIR:-/tmp}/jj-ws/<repo>/`.
4. **SWARM (`<= 15` concurrent `haiku/low`):**
   - Launch `k` `vic-superhaiku` workers per ready DAG unit with exact `agent-tier-gate.sh` labels (`description: "haiku/low: u1a0 <title>"`, `model: haiku`, `<= 5 min` cap, `timeout 60..120` per command, ZERO `jj`/`git`).
5. **JUDGE (`vic-judge`, `haiku/low`):**
   - Runs each unit's oracle + negative control independently across `u<N>a0..a<k-1>` (verifying freshly rebuilt binaries). Picks first verified passer.
   - `0` passers -> ONE recompile of THAT unit (tighter spec) -> still `0` -> **VALVE**: escalate unit one tier with all failure receipts attached (NEVER round 3 at haiku).
6. **LAND (supervisor ONLY, linear in DAG order):**
   - Land winners linearly via `/jj` `scripts/jj-land-linear.sh`, abandon losers, clean up all attempt workspaces via `scripts/ws-fanout.sh cleanup`, run wave `LAND-VERIFY`, and verify ROI via `/ensemble` `scripts/ensemble-roi.sh`.

---

## 2. Hard Valves (non-negotiable)

- Baseline oracle passes before edits -> **STOP** (unarmed oracle; fix test before swarming).
- Unit fails 2 compiled rounds -> escalate tier with failure receipts.
- Judge reports `NOT-MECHANICAL` -> escalate tier immediately.
- Land conflict -> partition error: abandon conflicting unit and re-compile DAG cleanly.
- Full suite breaks post-land -> revert that land FIRST, then diagnose.
