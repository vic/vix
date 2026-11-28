---
name: compiler-craft
description: Compiler & verifier engineering laws (ANY language project) — data shape (SoA/intern pools), proof-carrying types, Datalog/rule analyses, arenas/regions/faults, build speed/caches, bootstrap independence, scaling oracles, and pay-per-use bars. Use before designing or ruling on a frontend, typer, analysis, IR, cache, allocator, backend, bootstrap, or compile-speed/memory bar.
---

# COMPILER CRAFT (vic, global)

**Stack:** `/vic-stack` (recall first) · `/oracle` · `/probes` (size on OUR whole workload — *"compiler X does it"* is never proof; measured gain on our workload is) · `/design-impl-workflow` (`references/soundness-and-invariants.md`).

**Assets in this skill:**
- `references/gates-and-oracles.md` — concrete recipes for bootstrap independence gate (file-open trace + mutant), pay-per-use split benchmark, `-fstack-usage` + `nm` inline gate, and reference-engine floor checks.
- `scripts/scaling-check.sh` — automated `n` vs `8n` scaling oracle (`<= 24×` instruction/time ratio) to catch hidden $O(N^2)$ / $O(N^3)$ pathologies before landing.

---

## 1. Data Shape (speed + memory start here)
- **Unified intern pool:** ONE intern pool for types AND values (`u32` IDs); equality = ID equality; values used inside types interned by NORMAL FORM. Shard with thread ID encoded in the ID for lock-free parallel interning.
- **Structure of Arrays (SoA):** Flat arrays of small IDs (`u8`+`u32` columns), never pointer trees. Indices survive region moves and halve pointer bytes.
- **Staged IRs with hard walls:** Untyped IR per file, typed IR per function; after lowering, ZERO reads back to AST/tokens/source bytes except error printing.
- **No persistent path-copy maps on hot paths:** Unique flat tables mutated in place; share by index.
- **Index by owner once:** Any scan of all IDs inside a per-item loop turns quadratic the day counts grow. Always benchmark BOTH realistic multi-unit trees AND adversarial wide/deep stress units (8k–16k nodes).

## 2. Types Carrying Proofs (errors unrepresentable at run time)
- Sizes/bounds in types (`Str(n)`, `Array[A](n)`) make OOB unexpressible: prove at compile time or reject — never an "interim" runtime trap or sentinel.
- Decidable arithmetic only (linear forms over immutable binders; no SMT in TCB). Two different normal forms are different — never "probably equal".
- **Certified values move:** A proven index carries its proof type across params/fields/returns and is never re-proved.
- **Flow-sensitive facts & scope separation:** Definitions kill facts mentioning them; operations that owe preconditions and credit postconditions check preconditions in the pre-scope and credit postconditions in a nested child scope only. Proofs cross calls in the signature (no hot-path interprocedural solve).
- An `else <default>` added to appease a checker is a sentinel — return an explicit `Option`/outcome.

## 3. Declarative Rule Analyses (Datalog-style)
- **Measure rows before speed:** Structured control-flow interval labels beat classic per-point closures by 10–100× fewer rows with identical verdicts.
- **Reference floor first:** Run a reference engine (e.g., Soufflé) on your real facts to measure the floor; if near the floor, the rules are the wall, not the engine.
- **Per-unit vs. global granularity:** Verify rule dependency graphs! Pooling 2,000+ units into one global solve triggers $O(U^3)$ cross-unit pairs. Run transaction-global rules once globally and intra-unit rules in per-unit reset/evaluate loops with callee summaries.
- **Pay-per-use triggers:** Compile rule plans ONCE; seed rule groups by trigger so units not using a feature pay `~0`. Keep rule text beside compiled plans and differential-test against reference engine on every land.
- **Unindexed filter atoms:** Watch comparison joins (`k^3`) with `scripts/scaling-check.sh` (`n` vs `8n <= 24×`).
- **Track `unproduced=<N>`:** Never report accepted while any declared input relation lacks a wired producer.

## 4. Memory & Stack Discipline
- Static last-use freeing + in-place update of unshared values + arenas/ID-indexed graphs for cycles.
- Carry explicit region operands on every allocating node from day 1 (avoid ambient global "current region").
- Separate **ephemeral scratch arenas** (released immediately before heavy downstream phases) from kept arenas; workers retain chunks between tasks to prevent massive minor-fault storms.
- Built-in subsystem memory accounting (1 load when off, split at global peak). Rank memory levers by **live bytes at global peak**, never first-touch fault attribution or requested malloc bytes.
- **Bounded stack:** Convert deep chain recursion to explicit iteration (or segmented stack); enforce with `-fstack-usage` and `ulimit -s 1024` stress runs.

## 5. Build Speed, Inlining & Caches
- **Content-addressed keys:** Hash compiler build, config, unit body, AND **verdict-relevant callee interface/contract fingerprints** (never timestamps or run counters).
- **C backend hygiene:** Emit explicit C types (fast compiler for dev, optimizer for release); watch cross-TU inlining loss (`static inline` + `nm` gate for hot helpers; LTO slow-path inlining inversions caught via `instructions:u`).
- Always measure "faster than X" on the same quiet host (cold + warm, lines/s, exact commands + versions).

## 6. Bootstrap, Independence & Bars
- **Fixpoint (`C2 == C3`) proves reproducibility, NOT correctness:** Stage 1 MUST also agree with the reference/seed on every positive verdict AND reject every negative test with its exact error codes.
- **Independence gate:** Copy the tree with the old system deleted, rebuild from seed, pass everything, AND verify with a file-open trace (`strace`) + mutant that puts one old read back (see `references/gates-and-oracles.md`).
- **Put core guarantees on the bootstrap path** (never retrofit type safety onto a self-hosted compiler written in an untyped style).
- **No fuel/thresholds changing semantics; no flag turning checks off; `KNOWN_GAPS.md` tracks every gap with a minrepro until deleted on fix.**
- **Whole-pipeline bars:** Size changes on the WHOLE pipeline (a change in phase A can move cost to phase B); report pay-per-use per class (uses feature vs. does not); compare correct-with-correct (never gate against an old broken build that skipped required checks).
