---
name: lanes
description: Never-stall parallelism & lane-partitioning law (ALL projects) — keep 7 operational lanes saturated (build, verify, soundness, recon, plan, hygiene, measure) with up to 5 file-disjoint coding lanes, explicit serialization on hot files, realistic 2-2.5x parallelism ETAs, and zero host/file collisions. Use at every dispatch decision and whenever waiting on anything.
---

# LANES LAW (vic, global) — zero idle gaps, zero file collisions

Waiting on one worker with empty lanes is a time crime. A blocked lane NEVER stalls disjoint lanes.

**Stack:** `/vic-stack` (RECON lane also runs `quipu` recall and `ircc` peer asks while BUILD runs) · `/workspace` (isolated `jj` workspaces) · `/jj` (linear landing).

**Assets in this skill:**
- `references/lane-ledger-template.md` — canonical `<proj>/vic/lanes.md` schema, serialization matrix, and realistic throughput rules.
- `scripts/lanes-check.sh` — mechanically checks a lane ledger or pair of `FILES` lists for file overlaps (both `src/` AND `test/` count files) and enforces the max-5 active lane cap.

---

## 1. The 7 Operational Lanes (coding is only ONE)

1. **BUILD** (max 5 parallel coding lanes in isolated `jj` workspaces on strictly disjoint `FILES`)
2. **VERIFY** (`vic-reviewer` + `LAND-VERIFY` on the LAST landed deliverable while the next builds)
3. **SOUNDNESS** (`@audit` / `vic-lawyer` asynchronous `[verify-commit]` -> `[verify-result]`; blocks dependent stacking, never disjoint lanes)
4. **RECON** (`vic-reader` / `vic-sweep` / `PROBE` pre-measuring inputs for the NEXT 1–2 tasks while current runs)
5. **PLAN** (persistent designer / `vic-planner` hardening the NEXT brief while current runs so implementer never idles)
6. **HYGIENE** (`vic-scribe`: `HANDOFF.md`, `state.md`, `lanes.md`, playbooks, tracker updates)
7. **MEASURE** (isolated perf agent — runs sequentially on a quiet host, never overlapping heavy builds)

---

## 2. Disjointness & Host-Safety Laws

- **Disjoint means BOTH `src/` AND `test/`:** Two lanes that edit disjoint source files STILL collide if both update the same test-registration file or global count-assertion file. Assign distinct named anchors OR serialize explicitly.
- **Hot files serialize:** Central pipeline drivers, shared headers, global count tests, and shared static libraries run serially in one lane.
- **Host caps:** `<= 5` active coding lanes · `<= 3` concurrent full builds on one host · `1` perf measurement at a time on a quiet host (instruction counts are stable, RSS/wall need quiet host) · check `ps -ef` before rebuilding any shared library.
- **Realistic parallelism math:** 5 parallel coding lanes deliver ~**2–2.5×** wall-clock throughput (not 5×) because design hardening, diff review, and linear landing remain partially serialized. Forecast ETAs from measured velocity.
- **Subagent nesting truth:** Subagents cannot spawn subagents (1 level: lead -> workers). If a worker needs delegation, that is a partition error — split at the lead.

---

## 3. Saturation Protocol & Anti-Stall Self-Audit

1. Dispatch primary BUILD lane -> **immediately** spawn RECON (`PROBE`) + PLAN for the next 1–2 rungs in parallel.
2. Never wait with empty lanes: if waiting `> 60 s`, fill RECON / PLAN / HYGIENE first.
3. Priority infra unblocking: if a build/harness bottleneck stalls multiple lanes, pause feature lanes, land the single infra fix, and rebase all lanes onto it.
4. Keep `<proj>/vic/lanes.md` updated in the same turn as every workspace add, land, or drop; validate with `scripts/lanes-check.sh`.
