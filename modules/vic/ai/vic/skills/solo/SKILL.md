---
name: solo
description: Solo direct-delivery law (ALL projects). Use when told to work alone or when single-session execution beats multi-agent relay overhead. Zero subagent spawns; strict experiment-first loop (measure -> stub -> build -> mutant -> gate -> land), 2-try/3-fail self-stop, minimal code, and clean quiet-host timing. Triggers — solo, alone, no agents, do it yourself, don't delegate.
---

# SOLO DIRECT-DELIVERY LAW (vic, global)

**Stack:** `/vic-stack` — still recall `quipu` and `vic-recall` first, ask peers via `ircc`, and save verified results + `gebed_report`. Pair with `/probes`, `/oracle`, `/jj`, `/escalate`.

**Hard constraint:** You are alone. NEVER spawn new agents (`Agent` / subagent / fleet spawners forbidden). You may message already-existing peer sessions, but all execution runs directly with your own tools.

**Assets in this skill:**
- `references/solo-loop.md` — the exact 7-step solo experiment-to-land loop with self-enforced anti-rabbit-hole guards.
- `scripts/solo-gate.sh` — fast pre-commit self-check for solo runs (verifies `jj` health, diff minimalism / no banned tokens, clean-restore check, and quiet-host load before timing).

---

## 1. Core Solo Principles (Delivery = Landed Goal Delta)

Messages, verdicts, and notes are overhead — **landed movement on the goal** is output.
1. **Goal first, one step at a time:** Every unit states the exact gap it closes BEFORE writing code; beat the 1-worker baseline before multi-worker scaling. Zero off-path side quests.
2. **Experiment before code (`evidence-gate.sh`):**
   - Measure TODAY's `main` baseline on a quiet host (`load < 1.0`, no competing builds).
   - Size the lever with a throwaway 30-min release ablation stub (`verdict: STUB`) in a scratch workspace.
   - Under bar -> revert stub, mark `FAIL`, move on immediately (zero production code written).
   - Over bar -> revert stub, mark `PASS`, build the **minimal** change (`Δ+lines < Δ-lines` bias).
3. **Self-enforced anti-rabbit-hole cap (critical — `subagent-brief.sh` does NOT guard main sessions!):**
   - Count attempts explicitly. Same approach fails TWICE -> STOP and probe/measure before try 3.
   - 3 total fails -> HARD STOP, write `# ESCALATE` (`/escalate`), question architecture. Never spiral into hour-long debugging.
4. **Oracle + armed mutant + zero regression:**
   - Write RED check before code; kill at least one product-site mutant and prove clean restore (`sha256sum`); never land slower on ANY benchmark.
   - If the project gate cannot see the property you changed, add the check to the gate FIRST.
5. **Timing hygiene (the `vic-run` trap):**
   - Use `timeout 60..120` on every command.
   - **Avoid `vic-run` for clean wall-clock timings or mmap-heavy binaries:** `vic-run` applies `ulimit -v 8G` + `nice -n 10`, which can kill mmap-heavy tools with `ENOMEM` and skew wall numbers. Run clean benchmarks directly under `timeout` on a verified quiet host, recording commit SHA + dependency SHAs + exact command.
6. **Concise reporting:** Report to the owner in a few crisp lines when a rung lands or needs a decision; push full tables and receipts to `HANDOFF.md`, the experiments log, and `quipu`.
