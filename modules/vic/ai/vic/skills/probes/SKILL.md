---
name: probes
description: Experiment-based development, measurement, ablation, and isolation law (ALL projects) — MINREPRO shrink, flip tables, counters before theory, 30-min STUB ablation, evidence-gate.sh tickets, interleaved A/B confirmation, freshness law, and zero blind rework. Use BEFORE any optimization, bug-hunt, perf question, architectural bet, or trusting any prior number. Triggers — experiment, probe, measure, benchmark, ablation, stub, profile, bottleneck, minrepro, evidence ticket, perf miss.
---

# PROBES & EXPERIMENT-BASED DEVELOPMENT LAW (vic, global)

**Stack:** `/vic-stack` — recall `quipu` evidence and `vic-recall` before probing; save verified probe tables as `ledger:<proj>/evidence/<slug>`. Pair with `/oracle` (armed controls) and `/escalate` (stop after 2–3 fails).

**Core thesis:** *Be a scientist. Never guess, never optimize on intuition, never code a lever you have not sized.* A 2-minute falsifiable experiment beats 4 hours of confident wrong engineering.

**Assets in this skill:**
- `references/experiment-templates.md` — copy-paste templates for `MINREPRO`, flip tables, counter probes, ablation stubs, `evidence-gate.sh` tickets (`STUB`/`PASS`/`FAIL`), and interleaved A/B perf reports.
- `scripts/evidence-ticket.sh` — creates, validates, and transitions `<main>/vic/evidence/<ws>.md` tickets compatible with the global `evidence-gate.sh` hook.
- `scripts/ab-compare.sh` — runs interleaved same-host A/B measurements (`A, B, A, B, ...`) with `perf stat` / wall / RSS median reporting to kill noise and prove real deltas.

---

## 1. Mandatory experiment order (violating = thrash)

1. **MINREPRO (< 1 s):** Shrink the failing or slow case smaller than the goal (`0.01 s` repro >> `83 s` full run), preserving the exact error class or scaling behavior at every shrink step.
2. **FLIP TABLE (isolate 1 variable per row):** Build an equivalent PASS/FAIL or fast/slow twin differing in ONE variable. The flip pinpoints the responsible layer before you write a hypothesis.
3. **COUNTERS BEFORE THEORY:** Count what the shallow layer feeds the deep layer (allocations, calls, edges, emitted rows, misses). One counter kills weeks of wrong theory.
4. **ABLATION STUB = LOCUS PROOF (`verdict: STUB`, <= 30 min):**
   - Put a minimal throwaway early-return / no-op stub at the suspect locus on a **release inlined build** (`-O2` — un-inlined profiles locate, never size!).
   - Measure the **WHOLE workload** (realistic multi-unit + adversarial wide/deep stress input).
   - **Revert the stub byte-identical** (`jj diff` empty / `cmp`).
   - Require meaningful ROI (e.g., `>= 2–5%` on the whole workload). Under the bar -> set `verdict: FAIL`, kill the idea immediately, write **zero** production code.
5. **EVIDENCE TICKET (`verdict: PASS`) -> MINIMAL IMPLEMENTATION:**
   - Fill all required fields (`measured`, `locus`, `baseline`, `stub`, `predicted`, `evidence`, `verdict: PASS`) via `scripts/evidence-ticket.sh`.
   - Implement the smallest change that captures the proven lever.
6. **THIRD "MAYBE" RULE:** If you write a 3rd speculative paragraph without new measured data -> **STOP**, add a trace with IDs (not just tags), run, observe, and revert the trace before finishing.

---

## 2. The Freshness Law (supreme)

**NEVER build on a number whose probe setup you cannot see and rerun.**
- Always record the exact setup WITH every number: commit hash, dependency hash, compiler flags, input fixture, host state, and exact command.
- Always compare against a **same-host re-measured main-tip baseline**, never a stale cross-session or cross-lane row.
- Verify the benchmark fixture actually executes the intended pipeline (`rejects=0`, counter `>> 1`, all stages run) — an inert or early-rejecting benchmark measures nothing.

---

## 3. No blind perf rework & two-stage gating

- **Primary gates:** deterministic retired user instructions (`+1%` fails) and peak RSS (`+2%` fails, median of `>= 2` runs on a quiet host). Use `perf stat --no-inherit` when test harnesses spawn child processes.
- **Two-stage confirmation:** Screen on a perf agent -> confirm any gate miss with `scripts/ab-compare.sh` (interleaved same-input A/B on an idle host) before blocking or ruling.
- **On ANY gate miss:** The **ONLY** permitted next action is profiling (`callgrind` / `perf record` / `-fstack-usage`) or controlled ablation. Never tweak by intuition (blind tweaks regress repeatedly).
- **Cumulative drift:** Periodically compare wave-end vs. wave-start baseline (individual `+0.5%` commits compound).
- **Splits that matter:** one-time vs. marginal cost · construction vs. execution count · startup vs. compute · realistic tree vs. wide/deep stress tree · end-to-end vs. micro-kernel (micro-kernel-only multiples are BANNED as headline claims).
- **Run hygiene:** Cap commands with `timeout` + memory limits (except ASan virtual reserve and clean wall benchmarks where `vic-run`'s 8G VA / `nice -n 10` can skew results). Revert every investigation trace before landing.
