# Soundness, fail-closed verification, and code invariants (generic)

This reference collects deep architectural and low-level engineering laws distilled from building verified, high-assurance systems. Apply these during specification, design, brief writing, implementation, and adversarial audit.

---

## 1. Fail-closed verification architecture

### 1.1 Refuse every unmodeled construct by structure
- Maintain a live **construct census** listing every declaration, AST, IR, or protocol kind in the system and its verification status (`fully checked`, `partially checked`, `unmodeled`).
- Every unmodeled or partially checked construct MUST be refused unconditionally by **structural kind** (never skipped with `continue`, never exempted by name list) with a structured rejection code until its full checking phase lands.
- **Emergency stop vs. full refactor:** When a fail-open soundness hole requires a large refactor to check properly, ship a tiny P0 task that unconditionally refuses the construct *immediately*, then schedule the full checking refactor as a follow-up that removes the refusal.
- **Zero core/std-library exemptions:** Run the exact same fail-closed pipeline, naming rules, and verification checks on core/standard-library units as on user units. When checking user code against a frozen core image, apply user-only rules only to user units, report core vs. user rejection counts separately, and still return non-zero exit status if core rejections are non-zero.

### 1.2 Obligations keyed strictly on structure
- Generate verification obligations unconditionally from **structural presence** (every call-cycle member, every loop, every operation implementation, every resource allocation), NEVER conditioned on whether the user supplied a measure, annotation, or formable signature.
- Emit clearing facts only when valid evidence exists. If evidence is absent or malformed, leave the obligation uncleared so the verifier rejects it. Host/imperative code decides nothing.
- **Pre-check vs. post-credit scope separation:** Any operation that both *owes* preconditions and *credits* postconditions (function calls with contracts, assertions) MUST evaluate owed preconditions in the **pre-operation scope** and credit established facts in a strictly nested **child scope** containing only subsequent evaluation-order nodes. Otherwise an operation can self-justify its own preconditions (directly or transitively).

### 1.3 Declarative rule-system soundness guardrails
When a system uses a declarative rule engine (e.g., Datalog, constraint solver, policy engine) as its Trusted Computing Base (TCB):
1. **Track unproduced inputs (`unproduced=<N>`):** Any declared input relation (EDB) without a wired producer causes rules that negate or key obligations on it to fail silently open. Derive `unproduced` automatically from the single authoritative list of tables fed to the engine (never a hand-written count). Count a registered producer as produced even if it emits 0 rows on a given input. Never report full "accepted" while `unproduced > 0`. Ship each rule family atomically (producers + whole-program goldens + wiring).
2. **Functional-table uniqueness:** Guard existential clears on functional tables (type, signature, literal, arity) with duplicate-key rejection / universal negation so conflicting duplicate rows cannot slip through.
3. **Root-scope contradictions (`ex falso`):** Detect contradictions / empty abstract domains at root scope (while preserving unreachable sub-branches for dead-code diagnostics) so contradictory entry assumptions cannot vacuously discharge downstream obligations.
4. **Type-safe domain coupling:** When reducing one abstract domain into another (e.g., intervals -> order relations), require explicit type agreement (`type(x) == type(y)`) to prevent cross-type deductions or masked overflows.
5. **Symmetric 1-to-1 resource reuse:** Pair many-to-1 tie-breaking with symmetric 1-to-many concurrent tie-breaking at the same allocation site, enforce same-allocator/heap provenance, and exclude join points (prevents cross-heap theft, double-reuse, and join-point use-after-free).
6. **Transitive aliasing & container liveness:** Compute transitive alias closures and propagate upward/downward container liveness and frees gated by reachability.
7. **Tail-call stack soundness:** Exempt only direct *tail self-calls* from stack-bound call-cycle edges; mutual tail cycles still require stack bounds unless guaranteed tail-call elimination holds across all targets.
8. **Exact exemption width:** Every filter in a rule body that excludes a variant/kind cites the exact spec sentence authorizing it and is no wider than that sentence.
9. **Keep heuristic search outside the TCB:** Heuristic synthesis, search, or LLM proposals may propose candidate facts/proofs; only the single deterministic verifier admits them.
10. **Granularity hygiene:** Verify dependency graphs between rule families before choosing evaluation scope. Run transaction-global rules once globally and intra-unit rules in per-unit reset/evaluate loops with callee summaries (prevents global $O(U^3)$ cross-unit blowups).

### 1.4 Namespace & subject isolation
- Assign every distinct semantic entity kind (syntax nodes, IR operations, CFG points, SSA values, expressions, scopes) a distinct non-colliding ID prefix/namespace.
- Explicitly exclude reserved system/internal namespaces from user-entity classifiers so unmodeled system facts never fall through into generic user paths.

### 1.5 Structured rejections vs. fatal infrastructure aborts
- Strictly separate **recoverable domain defects** (malformed inputs, wrong arity, unbound variables, unmodeled operations) from **infrastructure errors** (I/O failure, OOM).
- Domain defects emit structured rejection rows with exact source coordinates (`<path>@<byte-offset>\t<code>`) and fail the check cleanly — never abort early before reporting rejections, and never silently skip.
- Print executed pipeline steps honestly (`steps=...`, `unproduced=<n>`) derived directly from runtime result state (never a hardcoded `printf` literal).

---

## 2. Type-enforced code laws ("Make illegal states unrepresentable")

1. **Validate once at entry ("Parse, don't validate"):** Construct validated wrapper types at a single boundary (e.g., `ValidatedUnit`) and delete now-unreachable downstream error variants so inner lookups are pure and total. Validate cross-table invariants (non-null pointers, matching counts, in-bounds indices) once at entry with zero silent fallback.
2. **Closed enums & typed outcomes:** Never use raw integer codes, overloaded sentinels (`-1`, `0`, `UINT64_MAX`), or bare `bool`s that conflate semantic absence with OOM/I/O errors. Use closed outcome enums (`Formed | NotFormable | OutOfMemory`) paired with payload structs. Return canonical outcome structs directly rather than mirroring them through redundant translation switches.
3. **Exhaustive switches without `default:`:** Omit `default:` on closed-enum switches so `-Wswitch -Werror` breaks the build the moment a new variant is added. Initialize result variables before the switch, assign in every explicit case, and return once after the switch (satisfies `-Werror=return-type` and `-Werror=maybe-uninitialized`). Arm with a compile-fail mutant deleting one `case`.
4. **No parallel arrays:** Never pair separate arrays by index; store coupled fields together in structs.
5. **Single Source of Truth:** Keep exactly one canonical copy of keyword tables, primitive tables, canonical number parsers/printers, dependency-graph edge walkers, fed-table lists, pipeline step maps, and shared traversal loops.
6. **Ban test-only plumbing:** Verify every verification input field is populated on the *production* driver path, not only in unit-test harnesses. Prefer per-unit indexed arrays over global single-target struct fields.

---

## 3. Memory, buffers, and low-level systems invariants

1. **Producer-derived buffer/arena capacities:** Compute every pre-allocated slice capacity ("room") from the exact same traversal quantity/predicate the writer loop iterates — never an ad-hoc multiplier (`2 * n`). Expose and test the capacity computation directly AND mutate the actual allocation site (intra-arena OOB is invisible to ASan!).
2. **No fixed-size text buffers:** Size formatted symbols, identifiers, and signatures dynamically from their parts in an arena so OOM strictly means allocator exhaustion, never arbitrary length truncation. Never alias a shared static scratch buffer across calls that both retain views into it.
3. **Arena lifetime hygiene:** Audit resource/arena release on *every* return/error path. Put ephemeral scratch allocations in a dedicated scratch arena released immediately before heavy downstream stages (prevents peak RSS bloat).
4. **Bounded stack & iterative chains:** Never recurse linearly with input length/chain depth. Convert deep-chain recursion to explicit iteration and verify with `-fstack-usage` and low-stack stress tests (`ulimit -s 1024`).
5. **Safe empty arrays & arithmetic boundaries:** Never back a zero-length array with `NULL` if branchless/speculative masked indexing can touch it — use a valid aligned `static const` dummy sentinel. Explicitly test integer wraparound boundaries (e.g., `offset = UINT64_MAX - k` on multi-byte reads).
6. **Strict aliasing & hot loops:** Keep hot loop accumulators in plain local scalars without unnecessary `&local`. Mark hot cross-TU helpers `static inline` (`always_inline` where critical) and verify zero out-of-line symbols with `nm`.

---

## 4. Canonical encoding, content-addressed identity, and protocols

1. **Bijective canonical encoding (`decode(b) = Ok(o) ==> encode(o) == b`):**
   - Reject every non-canonical byte sequence on decode: overlong varints (e.g., non-minimal LEB128), boolean bytes outside `{0, 1}`, negative zero (`-0`). Normalize `-0` everywhere in encoders and literal checkers.
   - Enforce topological DAG ordering (`child < parent` / `index < bound`) across all node, type, and fact tables on decode to reject cycles and forward references.
   - Never encode provisional indices, placeholder types, or unresolved states into persistent or hashed artifacts.
2. **Content-addressed identity (two hashes when proofs exist):**
   - Runtime identity hashes executable semantics without proof-only annotations; verdict cache keys hash EVERY input that can change a verification verdict, including callee contracts/summaries.
   - **Mutual-recursion groups (SCCs):** Canonicalize members with self-group placeholders, sort lexicographically (fail closed on byte-equal ties as ambiguous rather than picking arbitrary order), re-encode with canonical sorted member indices, and domain-separate hashes.
3. **Formatter / renderer round-trip laws:** Define round-trip invariants over canonical leaf text + AST kind/arity + idempotence (explicitly specifying normalized literal forms such as hex -> decimal).
4. **Protocols, concurrency, and replay:**
   - Guard mutating RPC/protocol operations with optimistic compare-and-swap (CAS) revision headers (`on <rev>`) rejecting stale edits atomically with zero partial apply.
   - Keep compact columnar/wire encodings strictly read-only (server -> client); keep authored writes in unambiguous canonical syntax.
   - Pin binary/schema identity hashes in replay journals to detect divergence immediately, and report declared vs. observed coverage honestly.

---

## 5. Language frontend, scoping, and pattern-lowering invariants

1. **Uniform binder levels:** Every binding site that references or providers may target (including ignored `_` binders, unnamed parameters, unnamed capabilities/handlers) occupies a sequential binder level in source order so `first + i` addressing stays sound and aligned with lexical scoping.
2. **Dispatch on value/type evidence, never pattern syntax:** Match/case dispatch reads the scrutinee's declared type; when missing, fail closed. Never pick a permissive path from the first pattern's syntax.
3. **Share continuations & remap field binders:** Elaborate arm bodies once and share by node index across pattern alternatives, value intervals, and guarded fall-throughs; remap later guarded arms' field binders to the first arm's levels so all locals remain strictly bound and rename-invariant.
4. **Explicit interval-cut tracking:** Track an explicit `matched` flag per breakpoint during value-range cutting so gaps and sentinel endpoints (`max_high + 1`) route exclusively to the fallback/rest arm.
5. **Source-order bidirectional inference:** Run bidirectional type flow in *source order*, never normalized/swapped operand storage order (e.g., `a > b` stored as `Less(b, a)`). Never trust unverified stated return types across calls inside a local extractor — mirror only types established by the producer node itself.

---

## 6. Generated code & self-use (dogfooding)

- **Separate generated payloads from hand-written files:** Never store hand-edited files in directories wiped by generators. Keep design-side generators out of the runtime repository; transfer generated payloads via `sha256sum -c` manifest couriers.
- **Verify generators semantically:** Verify mechanical translators via back-translation (`export(gen(spec)) == canonical(spec)` modulo clause order) + full golden suite + `stats.txt` zero-unmapped/zero-leftover audit.
- **Atomic coordinated renames:** When renaming tables, relations, or error codes, update specs, producers, rule units, and goldens in one coordinated atomic task.
- **Self-use:** Whenever a new language or system guarantee lands, queue a follow-up task updating the project's own core/self-hosted code to use it.
