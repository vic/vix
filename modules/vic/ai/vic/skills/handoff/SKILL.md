---
name: handoff
description: Session continuity protocol (ALL projects) — mid-work checkpointing (bad-network law), HANDOFF.md + state.md discipline, spec-to-disk. Use at task boundaries, before risky long ops, ALWAYS before session end. Hooks enforce at ctx ≥70%.
---

# HANDOFF LAW (vic, global) CVMN — network dies; disk survives, context doesn't.

## CANONICAL RESUME FILE = <proj>/vic/HANDOFF.md (hooks enforce)
OVERWRITE (history → state.md), ≤25 lines: `UPDATED · DOING · NEXT-CMD (verbatim commands) · THEN · OPEN · FILES UNCOMMITTED · BURN (<model>/<tier> ~<tok> <mins>m) · RULES PULSE`. Update triggers: task end · ctx ≥70% (stop-gate hook BLOCKS stop until fresh) · before risky long op · session end. session-boot hook points every fresh session at it — restart > compaction, ALWAYS. Delegate the write to vic-scribe w/ facts when context hot.

## MID-WORK (not just session end)
Checkpoint EVERY major result AS FOUND (roots, ruled-out paths, probe numbers, derivation steps) → note file or state.md. Design-note-to-disk BEFORE code (survives disconnect; becomes agent spec verbatim; forces the math on paper first). Agents append report files per step; supervisor checks disk b4 re-dispatch after agent death (receipt: dead agent's disk WIP was complete+green — salvage ≫ redo).

## TASK END (every task)
1. state.md: PREPEND block ≤15 lines — keystones, tallies, uncommitted, NEXT, BURN line (telemetry duty /ledger).
2. Track/notes: landed → LAW · killed → DEAD w/ receipt · new → OPEN. One section per fact; DEAD never deleted.
3. Investigation traces REVERTED (diff clean); env-gated probes KEPT.
4. Green-tree re-verify AFTER revert (paste tally).
5. Memory: hard lessons only, CVMN, dedupe.

## SPEC-TO-DISK RULE
Spec >5 lines lives in a FILE, not only the Agent prompt. Dispatch references the file (re-dispatch verbatim; vic audits; crash loses nothing). Never end leaving: failing tree unreported · agent in flight unaccounted · spec only in context.
