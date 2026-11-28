---
name: dnet
description: >
  Enable when working on Δ-Nets (dnet) and Rust interaction-net runtime/compiler work.
  Enforces paper-exact Δ-Net semantics (references/deltanets-paper.tex), type-enforced Rust
  invariants (zero unwrap/panic/unsafe shortcuts), structural erasure, confluence/parallelism
  oracles, and minimal code. Re-read when in doubt.
---

# Δ-Nets (`dnet`) & Rust Implementation Law

**Stack:** `/vic` · `/vic-stack` · `/probes` (ablation & counters before optimization) · `/oracle` (differential + confluence + mutant oracles) · `/jj`.

**Paper is law; code is disposable.** The complete verbatim source of Daniel Salvadori's *"Δ-Nets: Interaction-Based System for Optimal Parallel λ-Reduction"* lives in `references/deltanets-paper.tex` — **cite exact line numbers** from it before ruling on any interaction rule, level delta, fan, eraser, or readback behavior (never trust memory!).

**Assets in this skill:**
- `references/deltanets-paper.tex` — full verbatim LaTeX source of the Δ-Nets paper for exact line citations.
- `scripts/dnet-check.sh` — static Rust hygiene & invariant gate (flags `unwrap()`/`expect()`/`panic!`/`todo!`/`unimplemented!`/`unreachable!`, `#[ignore]`, and clippy warning suppressions in non-test code).

---

## 1. Δ-Nets Paper Section Map (`references/deltanets-paper.tex`)

| Section | Lines | Use For |
|---|---|---|
| Abstract & Overview | `L172–L184` | Scope and claims |
| §1 Introduction | `L185–L367` | Background, sharing vs. optimal reduction |
| §2 Core Interaction System | `L368–L794` | Agents (`λ`, `@`, `ϵ`, `Δ`, replicators), level deltas, exact rewrite rules |
| §3 λ-terms -> Δ-nets | `L795–L964` | Translation, binder wiring, fan placement |
| §4 Δ-nets -> λ-terms (Readback) | `L965–L1103` | Readback, level tracking, sharing preservation |
| §5 Conclusion | `L1104–L1212` | Confluence & optimality properties |

---

## 2. Hard Rust & Δ-Net Implementation Invariants

1. **Make illegal net states unrepresentable:**
   - Newtypes for `NodeId`, `Port`, `Slot`, `Level`, `Delta` — never bare `usize`/`u32`/`i32` mixed across domains.
   - Derived flags/caches (e.g., erased/auxiliary port metadata) MUST be enforced at the **write site** (`write_port`) so `flag <=> wire` can NEVER diverge. Zero read-site band-aids.
2. **Zero crash paths in non-test Rust:**
   - No `.unwrap()`, `.expect()`, `panic!()`, `todo!()`, `unimplemented!()`, or `#[allow(warnings)]` in production modules. Propagate typed `Result<T, E>` with closed error enums.
   - Zero `cargo clippy -- -D warnings` warnings.
3. **Structural erasure & neutral terms:**
   - Erasure MUST be **structural** — full normalization under binders diverges on cyclic encodings with neutral inputs. Always test neutral terms, not only closed data!
4. **CPU parallelism law (measured receipt):**
   - Bulk-synchronous rounds with per-round $O(n)$ discovery are ~70× slower on CPU. Use **incremental per-worker frontiers + local resume** ONLY.
5. **Oracles & mutants (every rung):**
   - **Differential / confluence oracle:** `parallel == sequential` AND `net_reduce == reference_lambda_eval` on sharing-heavy inputs (numeral applications, church/fixpoint terms — trivial terms hide sharing bugs!).
   - **Counter sanity:** Assert interaction/rewrite counter `>> 1` before trusting any benchmark number.
   - **Minimal repro `< 1 s`:** Shrink failing terms smaller than the goal before touching code; run `scripts/dnet-check.sh --repo .` before landing.
