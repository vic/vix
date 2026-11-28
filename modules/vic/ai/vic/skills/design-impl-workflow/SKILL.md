---
name: design-impl-workflow
description: Design-and-implementation workflow law (ALL projects) — how a design lead, a persistent designer, an implementation dispatcher, coding agents, perf agents and an adversarial auditor build software together with proof. Covers roles, the task loop, brief writing, brief gate, fail-closed soundness, type-enforced code laws, oracles, mutants, deterministic perf gates, ablation, parallel lanes, escalation after failures, audits, hooks/verifiers/reports, and doc/tracker upkeep. Use before writing a spec, brief or ruling, before dispatching or accepting a coding task, before landing a change, when a gate misses, when an audit finding arrives, or when a task failed twice. Triggers — brief, dispatch, accept, land, lane, oracle, mutant, perf gate, ablation, ruling, audit finding, fail-closed, critical path, verifier, hook.
---

# Design and implementation workflow (generic, all projects)

This skill is the working method. It holds no project facts. Project names, file names, task IDs, and numbers live in the project's own notes. Where this text says "the project's law file", read the project's own rules.

**Read order when starting a session:**
1. This file (`SKILL.md`).
2. `references/brief-template.md` before writing or hardening a brief (includes `TASK`, `PROBE`, and `LAND-VERIFY` templates).
3. `references/gates-and-boxes.md` before sending or accepting a brief.
4. `references/soundness-and-invariants.md` before designing verification rules, encodings, types, or system boundaries.
5. `references/hooks-and-verifiers.md` before wiring automated hooks, static/runtime verifiers, or structured reports (`scripts/` holds ready-to-run POSIX `sh` verifiers).
6. `references/lessons.md` once per session.

Related skills: `/jj` (Jujutsu VCS law & linear landing), `/workspace` (isolated VCS workspaces), `/probes` (experiment-first measurement & ablation), `/oracle` (oracle shapes & mutants), `/dispatch` (model and effort per task), `/lanes` (parallel lane saturation), `/pie` (purpose before elements), `/handoff` (resume files), `/escalate` (repeated failure).

---

## 0. The goal rule

Every project has one goal that ends in a measurable state (for example: "the compiler rebuilds itself byte-identically, agrees with the reference implementation on every positive verdict, and rejects every negative test with its exact error codes"). Judge every action by one question: **does it move the critical path to that goal?**

- A task that cannot state in one line how it moves the critical path is not sent.
- Off-path items (minor drifts, refactors, P1/P2 audit findings, non-blocking optimizations) go to a queue and ride as **riders** on the next brief that already touches that file or phase.
- Throw-away work (code or interim guards a known upcoming task immediately deletes) is not briefed. Exception: a tiny P0 fail-closed stop landed immediately to close an active soundness hole while a multi-step checking refactor is built.
- **Priority infrastructure unblocking:** If a shared build/test bottleneck causes multiple lanes to time out or stall, pause feature lanes, land the single infrastructure fix first, and rebase all active lanes onto it.

---

## 1. Roles and authority boundaries

| Role | Does | Never does |
|---|---|---|
| **owner** | sets goals and laws, corrects the method, controls context wind-downs | is asked what a spec already decides; is quoted to the implementer |
| **design lead** | owns critical path, reads specs/diffs, triages audits, dispatches briefs, verifies evidence, commits, lands linearly, updates tracker/handoff/ledgers | writes production code or test bodies, runs bulk builds/suites/probes itself (delegates via `LAND-VERIFY` / `PROBE`), edits implementer notes |
| **persistent designer subagent** | revises the named brief, writes rulings, derives expectations, requests `PROBE`s, stages briefs (`sha256`); one task at a time; continued, not respawned | builds, runs suites, runs state-changing VCS commands, edits lead handoff/state files, sweeps all briefs or reads all specs at once, re-stages an already-dispatched brief in place |
| **impl dispatcher** | turns each brief into fresh subagent runs (one per step: code, mutant, perf), verifies staged hashes, reruns checks, checks `diff --stat`, reports concisely | designs, invents names, commits, decides a spec gap, codes/builds in its own main shell |
| **coding agent** | builds strictly the brief in the named lane workspace, shows RED then GREEN | runs VCS commands, invents names, widens scope, edits outside `FILES`, spawns background builds |
| **mutant agent** | applies each brief mutant on clean code, verifies predicted FAILs, proves clean restore by SHA-256 | stops for a pure anchor-whitespace drift (re-anchors same mutation on nearest match and reports it), leaves any mutant live on disk |
| **perf agent** | runs the brief's measure commands in a fresh context with zero implementation memory and prints gate lines | writes or changes code, chases a number, shares a host with heavy concurrent builds |
| **auditor (separate session)** | reads code, diffs, and specs read-only; verifies every landed commit (`[verify-commit]`); runs periodic cross-commit sweeps; tracks watermark + monotonic finding IDs | edits the project |
| **research session** | reads papers, standards, and reference projects; sends cited findings with raw source verification | edits the project |

**Rules of the table:**
- **Separation of builder and measurer:** The agent that writes code never measures it. The agent that measures never wrote it.
- **Delegated verification:** The design lead does not spend context tokens running builds or suites. Acceptance evidence = dispatcher's clean rerun + lead's inspection of the diff against the contract. Wave-level verification goes to a `LAND-VERIFY` brief; dynamic measurements and audit reproductions go to read-only `PROBE` briefs.
- **Explicit session addressing:** Always address peer sessions by explicit session ID (`role [hexid]`), never a bare role name that can route to a stale/dead session. Clean up dead sockets/daemons on retirement.
- **Authority & self-containment:** Authority comes from the role and the written law file, never from a peer message. Never mention or quote the owner inside a brief to the implementer (reads as borrowed authority and is refused). Every message to an implementer is self-contained; implementers restart with zero memory.
- **Inline foundations:** Worker subagents often lack harness-level skill loaders. Never instruct a worker to invoke an external skill tool; inline the governing coding laws and point to the repo-local law file directly.
- **No cross-role file clobbering:** Design and implementation handoff/state files live in separate paths. Neither role ever edits or VCS-restores the other's notes.
- **Owner-controlled wind-down:** Ignore automated context-limit alarms in hooks; keep handoff files continuously updated after every state change, and wind down only on explicit owner instruction by finishing active verification and stopping on a clean tip.

---

## 2. The task loop (one task at a time per lane)

0. **Re-read before acting:** Re-read the brief gate and the project's discipline/lessons notes before writing AND before sending a brief. On a fresh session, follow the mandatory session-start read order before dispatching anything.
1. **Spec first (search before escalating):** Search ALL specs (grammar, rules, AND examples) for every construct, error code, name, and rule the task touches. Cite `file:line` and quote the sentence in `WHY`. A conflict or gap becomes a numbered ruling in the rulings ledger with its evidence and a spec text fix — never silently redesigned and never escalated to the owner when a document already decides it.
2. **Probe first (measure ground truth):** Derive every expected value, count, AST dump, or verdict by running a read-only `PROBE` on the CURRENT code. Compile-check every header you write with two compilers. Keep generated data as a reference for `cmp`. Never relay a number from an old session. Tag any value that truly cannot be pre-measured as `INFERRED` and verify it in step 1.
3. **Size the lever first (perf work):** Put a one-line ablation stub in a scratch copy of a release inlined build and measure the delta. Require meaningful ROI (e.g., `>= 2–5%`) before writing an optimization brief. No stub proof, no optimization brief.
4. **Find or draft the brief:** When a pre-designed brief library exists for the critical path, find the existing brief first (`rg -l` by goal, title, ticket ID, keywords) — never draft from scratch or memory. Edit only what is stale or new; leave a correct brief byte-identical. Stage large exact text / payloads as staged files with a `sha256` manifest.
5. **Run the brief gate (section 7 + `scripts/brief-gate.sh`):** Fix every failure, open every cited ruling and verify each step against it, then stage and dispatch. Never re-stage an already-dispatched brief in place (use `<ID>-v2` + new `sha256`).
6. **Dispatch:** The dispatcher verifies every staged `sha256` first, then launches ONE code agent with the exact model, effort, and 10-minute cap named in the brief.
7. **RED then GREEN:** The coding agent writes new checks first, proves RED with exact expected failures, implements, builds with zero warnings, and proves GREEN.
8. **Independent rerun & diff check:** The dispatcher reruns the build, unit tests (every compiler + sanitizer), project checks, and golden checks in the lane path, and verifies `diff --stat` matches `FILES`.
9. **Separate perf agent:** A fresh perf agent (no implementation context) measures on a quiet host and prints gate lines against fresh main-tip baselines.
10. **Mutants & clean-restore proof:** The mutant agent runs every brief mutant (proving predicted FAILs), restores clean files from saved snapshots, and proves byte-identity by `sha256sum` / `cmp`.
11. **Acceptance by evidence only (section 9 + `scripts/land-gate.sh`):** The design lead verifies evidence, SHA-256 restore proof, zero mutant residue, and diff against contract.
12. **Land, notify auditor, record, keep busy:** Land linearly onto `main`, send `[verify-commit]` to the auditor immediately, update tracker + handoff + lane ledger + state ledger + perf ledger + docs in the same turn, and dispatch the next ready brief immediately. The dispatcher never sits idle.

---

## 3. Time, sizing, parallel lanes, and VCS hygiene

- **10-minute task cap:** Every task fits ONE agent in at most 10 minutes (build ~30 s). Too big -> split into `-a`, `-b`, `-c` sub-briefs before sending. Every command inside a task runs under `timeout` (1–2 min max) and a memory limit (except sanitizers that reserve huge virtual address space). A time-out is a datapoint to report, never a reason to wait.
- **Fast isolated tests:** A single isolated unit test runs in under 1 second. Only full compilation may take longer.
- **Parallel lanes (max 5):** At most five concurrent lanes on strictly **DISJOINT** files. Disjointness includes BOTH source files AND test/registration/count-assertion files (each lane uses its own named registration anchor; tasks sharing central wiring or global test-count assertions MUST be serialized explicitly).
- **Realistic parallelism math:** 5 parallel implementation lanes yield ~2–2.5x wall-clock throughput (not 5x) because design, brief hardening, landing, and verification remain partially serialized. Use empirical velocity for ETAs.
- **Isolated lane workspaces:** Each extra lane runs in its own VCS workspace created by the design lead under a runtime directory (e.g., `jj workspace add <runtime>/<lane> -r <main-tip>` or `git worktree add`). Every lane has its own `build/`, scratch, cache, and log files — lanes share zero output or verdict files. Worker agents run NO VCS commands.
- **Linear landing only:** The design lead lands lanes linearly onto `main` (rebase onto tip, never merge commits, never interactive cross-lane squash across dirty workspaces), verifies `divergent() | conflicts()` is empty, removes the workspace, and runs a wave-level `LAND-VERIFY` on the combined tip. A land conflict requiring a hand merge is a partition error: drop the lane and re-spec it.
- **Blocked lanes never stall others:** A failure or perf investigation on one file does not pause work on disjoint files.
- **Pre-VCS status gate:** Always inspect `jj st` / `git status` before moving the main working copy, rebasing, or committing. If unexpected changes exist, STOP and handle them first. Never chain `jj st && jj new`. Never commit while an agent is in flight in the same working copy.
- **Concurrency cap & shared artifacts:** Cap concurrent heavy builds on one host (e.g., `<= 3`). Before rebuilding a shared library or artifact, check active processes (`ps -ef`) for any peer builds linking it and coordinate a quiet boundary.
- **Guarded atomic log writes:** Never redirect directly (`> perf-log.tsv`) after a command that can fail. Write to a temp file, chain with `&&`, assert sanity (e.g., `new_rows >= old_rows`), and atomically `mv`.

---

## 4. Laws of the code (every task, every agent)

See `references/soundness-and-invariants.md` for full architectural rationale and patterns.

1. **Illegal states are unrepresentable:** Closed enums for every kind, never integer codes. No overloaded sentinel values (`-1`, `0`, `MAX`) or bare `bool`s conflating domain absence with OOM/I/O errors. Use typed outcomes (enum kind + payload). No parallel arrays paired by position: use structs. Validate invariants once at entry into a validated wrapper type and delete now-unreachable downstream error arms. A derived flag that can disagree with its source IS the bug.
2. **Fail-closed exhaustiveness (zero `default:`):** Omit catch-all `default:` arms on closed-enum switches so `-Wswitch -Werror` enforces compile-time exhaustiveness when a variant is added. Initialize result variables before the switch, assign in every case, return once after the switch. Refuse every unmodeled AST/IR/declaration kind explicitly by structure — never skip silently with `continue`.
3. **No crash path or placeholders in production:** No `abort`, `trap`, `exit`, `panic`, assert-to-crash, `"unsupported"`, `todo`, `fixme`, `skip`, `stub`, placeholder, or `"later"` in code, tests, comments, or output. Every unhandled case is a typed failure value or structured rejection row with a named spec code, fail-closed.
4. **Errors propagate; zero silent fallback:** Separate recoverable domain defects (structured rejection rows `<path>@<offset>\t<code>`) from infrastructure errors (I/O, OOM). No silent fallback to another tool, path, or default. A missing tool is an error naming it. Audit resource/arena release on every exit path.
5. **Single producer / Single Source of Truth:** Parse once, compute once. One canonical copy of keyword tables, primitive tables, number parsers/formatters, edge walkers, fed-table lists, and pipeline step maps. Nothing computed that nothing reads; no test-only plumbing; every phase wired into the production driver in its own task or the next named task.
6. **Producer-derived capacities & no fixed text caps:** Size formatted symbols/strings dynamically in an arena — never fixed-size stack buffers that silently truncate. Precomputed buffer/slice capacities MUST derive from the exact traversal quantity the write loop iterates (shared predicate/counter), never ad-hoc multipliers.
7. **Performance is a gate from line 1:** Nothing lands slower or larger than the previous accepted step without ablation proof and a ruling. State the complexity of every new loop and lookup and the spec bar it meets. Per-item lookups are indexed; recursion depth is bounded (use iteration on deep chains so stack never grows with input).
8. **Determinism & canonical identity:** Zero dependence on map/interning order, thread count, wall clock, or machine. Canonical bijective encodings reject non-canonical forms (`-0`, overlong varints, non-binary booleans) and enforce DAG ordering (`child < parent`) on decode.
9. **Fix invariants at the producer:** Never patch around a broken invariant at a reader. No workarounds, name lists, or text matches standing in for real IDs/graph links.
10. **Names are full readable words:** No 1–2 letter identifiers (except standard short prepositions/conjunctions where the project allows), no names ending in digits. Macros get full names.
11. **Least code that fully does the task:** No unrequested options, flags, layers, or files. Prefer changes that delete dead code/workarounds.
12. **Hot cross-TU helpers stay inline:** A hot helper shared across translation units MUST be `static inline` (and `always_inline` where critical) in its header, with call frequency noted in the brief and gated via `nm` for zero out-of-line symbols.
13. **Zero warnings across compilers & sanitizers:** Zero warnings on all configured compilers (e.g., GCC + Clang with `-Wall -Wextra -Werror -pedantic`) and on ASan+UBSan (`detect_leaks=1`). No suppression comments; only explicitly listed environment warnings are permitted.
14. **Structured edits & safe shell:** Multi-line edits use structured editor tools only (never multi-line `sed`/`perl`/`awk` or `truncate`). Scripts are POSIX `sh` unless explicitly specified. Never add a language, tool, or dependency without owner approval and a written reason.
15. **True exit codes & bounded processes:** Capture command output to a file, then `echo EXIT=$?` immediately after the command itself — never after a pipe. Kill child processes only by PID captured via `$!`; never `pkill -f`, `killall`, or `pgrep -f`. Never poll with `sleep`.
16. **Tests never govern the spec:** Never weaken, skip, or delete a test to make it pass. Never edit an expected value to match buggy code: stop, independently derive the spec truth, and report the mismatch.

---

## 5. Oracles, verification, and tests

- **Oracle first:** Write the deciding check before the code. Prefer two independent paths agreeing (implementation vs. independent reference tool, different language, or differential stage-to-stage oracle with `ddmin` delta minimization).
- **Whole-program integration over isolated slices:** Evaluate golden suites against the complete combined rule/verification program, not only isolated per-family slices, so cross-family obligations and interactions are caught.
- **Exact, independently derived oracles:** Derive expected digests, byte encodings, and rejection counts independently from the spec — ban weak `count > 0` or copied-from-code assertions.
- **Tests have zero authority over the spec:** A test asserting a bug may change ONLY with a numbered ruling giving an independent derivation of the new value. A gate miss blocks acceptance and is never relabeled "new baseline".
- **Armed negative controls:** Every check ships with a negative control proving it FAILs on a bad input or mutant, followed by restore proof. An unarmed check or a zero-count scan with no positive control is zero evidence. Accept tests name which obligation they clear and by which fact.
- **Fixture hygiene:** Every fixture is a legal program per spec (probe with the parser first), uses full-word names, exercises shared structure where applicable, and lists full index tables + every changed expectation when sorting shifts indices. Derive hand-computed indices in a comment verified against a listing.
- **Valid benchmark/integration fixtures:** Verify fixtures actually pass through all intended pipeline stages (`rejects=0`, `steps=...`). Never benchmark or gate on an early-rejection path.
- **Multi-oracle hardening arsenal** (apply where relevant):
  - Multi-compiler (`gcc` + `clang` `-O2 -Werror`) + ASan/UBSan (`detect_leaks=1`).
  - Compile-and-run oracle for emitted code + `-O2` disassembly check (`objdump`) for security/hardening barriers.
  - Static stack-usage gate (`-fstack-usage`) + constrained-stack stress test (`ulimit -s 1024`) on wide/deep inputs (8k–16k nodes).
  - Sharded order-independence shuffle tests (`cmp` across seeds and thread counts).
  - Multi-transport byte-identical parity + 1,000-request flat-RSS leak check (`0 KB` growth).
  - Bidirectional generator round-trip oracle (`export(gen(spec)) == canonical(spec)` + `stats.txt` zero-unmapped audit).
  - Kill timer on every test that spawns a subprocess.
- **Claims of absence:** Every "no existing X" claim cites the search command, its zero output, AND an armed control showing the same command finds a known item.

---

## 6. Mutants

- **Compilable, product-path mutations:** A mutant is an exact 1-line edit to production code that COMPILES with zero warnings (under `-Wall -Wextra -Werror`), alters the value the check actually reads at the **product site** (e.g., the allocation site, not just a test helper), and has ONE exact predicted outcome naming every failing check.
- **How to mutate cleanly:** Mutate a condition, constant, argument, or string — never "delete the call" or "delete the loop" (leaves unused variables/functions and breaks `-Werror`), and never induce uninitialized memory reads (fake kills).
- **Compile-fail exhaustiveness mutants:** For exhaustive closed-enum switches without `default:`, include a mutant that deletes one `case` and assert the build FAILS with `-Wswitch`.
- **Predict cascades & dispatch rerouting:** A dispatch-predicate mutant reroutes inputs of BOTH paths (list both). An early-step failure cascades to every downstream dependent check (list all). Predict check NAMES, not multi-line free text, unless probed on a scratch copy.
- **Arm memory/sort/pipe mutants properly:**
  - Arena OOB mutants are invisible to ASan: arm with a value check at a non-zero offset.
  - Sort-removal mutants survive if the test loader pre-sorts inputs: use deliberately unsorted fixtures.
  - Length-bound mutants survive if the test closes a pipe early (`EOF`): keep the pipe open past the bound.
- **Read anchors, never predict them:** Before staging, read every mutant's `before` text in the real lane file and verify `rg -Fc == 1`. Mark counts for unwritten new code as `predicted`. If formatting shifts an anchor, the mutant agent re-anchors the SAME mutation on the nearest match, reports the exact edit applied, and proves clean restore.
- **Zero-waiver surviving mutants:** Every surviving mutant either proves dead/redundant code (delete it!) or exposes a test gap (strengthen the fixture until killed). List intentionally unmutated paths (e.g., OOM without fault injection) explicitly so gaps stay visible.
- **Mandatory clean-restore SHA-256 gate:** Save a clean snapshot (`mutant-save-<file>`) before mutating; restore after each mutant; prove `sha256sum` / `cmp` matches the clean snapshot AND verify zero mutant residue before landing. Never commit while a mutant is live.

---

## 7. The brief gate (run before writing AND before sending)

Run `scripts/brief-gate.sh` mechanically AND verify every item in `references/gates-and-boxes.md`:
- On the critical path (or attached queue rider); no throw-away work; wired into product path (or names the next wiring task).
- No duplicate of an existing producer; no shared-file or shared-test-count overlap with active parallel lanes.
- Ticket/bead ID on line 1 (zero tracker CLI hints); bead exists with real-only `blocks` edges, planned weight, and planned length.
- Spec lines cited (`file:line` + quote); **every cited ruling (including amendments) OPENED and verified against every step's logic**, not just counts.
- Every symbol/type/enum/field spelling verified against live headers; every expected value probed on current tip; headers compile on two compilers.
- Every name ruled (including static helpers); full fixture index table + every affected existing test expectation listed (verified by `rg`).
- Every mutant compiles (`-Werror`), hits the product site, has `rg -Fc == 1` anchor (or marked `predicted`), and lists one exact predicted outcome.
- Fits one 10-minute agent; model/effort named; self-contained with laws inlined (no external `Skill` tool calls); zero unfilled `<PLACEHOLDER>`s; every executed binary is built by a step; no pipe-masked exit codes; no sentinel values; no line-number edit instructions.
- `PERF` section included: separate fresh agent, baselines from newest `LAND-VERIFY`'d main tip on the same host, bar stated BEFORE the build.
- New language/system surface feature queues a self-use (dogfooding) task (section 12).
- Failure-pattern box (and rule-family box when touching declarative rules) filled with one concrete line per item.

---

## 8. Briefs and staging

Template: `references/brief-template.md` (covers `TASK`, `PROBE`, and `LAND-VERIFY`).
- **Pre-designed brief library:** Search existing briefs first; touch only the brief being dispatched and only where stale/new; never batch-edit briefs. Record facts needed by later briefs in the handoff and apply them when that brief is next to go.
- **Immutable staged files:** Stage exact briefs, headers, and payloads under a build/staging path with a `sha256` manifest; the dispatcher verifies every hash first and removes staged files on report.
- **Never re-stage a dispatched brief in place:** Any mid-flight correction MUST be written to `<ID>-v2` with a new `sha256` and explicitly dispatched (never message-only corrections, which create two conflicting sources of truth).
- **No implementation bodies in briefs:** Design writes headers, signatures, contracts, exact test specs, mutants, and commands — never production or test bodies.
- **Exact command reuse:** Verification briefs (`LAND-VERIFY`, `PROBE`) copy exact command invocations (with all CLI args and scoped `rg` paths) from the lane briefs they verify.

---

## 9. Acceptance and landing (by evidence only)

In this order, with the lane's agent idle (run `scripts/land-gate.sh` to automate checks 2–3):
1. **Read the report:** Rule every drift in one line each. Verify every claim against disk/source (a claim of "written" needs `ls`; dead agents often leave salvageable green work on disk; reviewers over-flag — spot-check).
2. **Verify evidence & clean restore:** Confirm RED run (if skipped, accept only if mutants kill 100% of new checks), clean rebuilds with zero warnings on all compilers + sanitizers, golden + integration checks, staged header hashes, clean-restore `sha256sum` for every mutated file, zero mutant residue, and `diff --stat` matching `FILES` exactly. Read every changed line against the contract.
3. **Commit & land linearly:** Commit in the lane with `<ID>: <title>`, rebase linearly onto `main` tip (never merge), verify `divergent() | conflicts()` is empty, forget/delete the lane workspace. For multi-lane waves, run `LAND-VERIFY` on the combined tip.
4. **Measure & gate perf:** Tag perf rows with the landed commit (and external dependency SHAs); gate via `scripts/perf-gate.sh` against same-host main-tip baselines.
5. **Notify auditor immediately:** Send `@audit [verify-commit] <commit-hash> <ID> (ticket <id>, brief <path>)`. Do not stack dependent work on a P0-flagged commit until `@audit` reports `CLEAN`.
6. **Update durable state & tracker in the same turn:** Record per-stage tracker reports + close ticket; update handoff, lane ledger, state ledger, perf ledger, queue riders, and docs; commit docs.
7. **Dispatch next brief in the same turn:** Keep the dispatcher continuously fed.

Never relay an unverified report to the owner. State plainly: **passed**, **failed** (quote exact error), or **skipped**.

---

## 10. Performance discipline

- **Deterministic gates only:** Gate every accepted task (including test-only tasks) on retired user instructions (`+1%` fails) and peak resident memory (`+2%` fails, median of `>= 2` runs on a quiet host). Wall time is informational, never a gate.
- **Two-stage confirmation:** Screen on the perf agent; confirm any gate miss with an interleaved same-input A/B run on the same idle host before blocking or ruling.
- **Fresh same-host main-tip baselines:** Always compare against the newest `LAND-VERIFY`'d main tip re-measured on the same host (never stale historical or cross-lane numbers). Record external dependency commit SHAs on every perf-log row.
- **Cumulative wave audits:** Periodically compare wave-end perf against wave-start baseline to catch cumulative creep from individually passing `+0.3%..+0.8%` commits.
- **Dual-shape workloads:** Benchmark BOTH realistic multi-unit trees AND adversarial wide/deep stress inputs (8k–16k nodes under constrained stack) to catch $O(N^2)$ and stack blowups early.
- **No blind perf rework:** On ANY gate miss, the ONLY permitted next action is profiling (`callgrind` / `perf record` / `-fstack-usage`) or controlled ablation. Never tweak by intuition.
- **Profiles locate, ablations size:** Un-inlined profiles exaggerate costs. Size levers with a one-line ablation stub on a release inlined build before briefing optimization; revert optimizations yielding `< 2–5%` ROI.
- **State bars before building; zero post-hoc waivers:** Same-output work gates on strict totals. Output-adding work gates per unit of output ONLY if a meaningful baseline denominator exists and the bar was stated upfront. Otherwise, prove required semantic work vs. host overhead via controlled step-by-step ablation, record a numbered ruling naming the cost bought, and queue overhead fixes.
- **Separate product vs. test cost:** Use `perf stat --no-inherit` when harnesses spawn child processes, and track test-suite instruction growth separately.
- **Count shallow-layer feed first:** Before blaming a deep engine/layer, measure how many items/rows the shallow layer feeds into it (and verify per-unit vs. global granularity).
- **Chase synthetic misses to invariants:** A small RSS miss on a wide/deep bench can mask a P0 stack overflow or leak; trace it to the invariant before accepting more work.

---

## 11. Rulings, specs, and soundness

- **Specs are law:** Notes, summaries, and model answers are insight only. Cross-check grammar, prose, examples, AND executable rules before ruling. Never invent error codes outside the spec — add them to the spec first in one canonical code list.
- **Numbered rulings ledger:** Every spec gap, conflict, interim acceptance, perf waiver, or changed test expectation becomes a numbered ruling (`Rnn`: ID, date, task, spec evidence lines, numbered decisions, spec text fix) written in the same turn, newest first.
- **Executable spec claims:** Every "owes" or "is rejected" spec sentence requires a minimal REJECT fixture plus an ARMED accept control run on the verifier before the rule family is briefed.
- **Structural obligations only:** Key every obligation on the structure creating the duty, never on the presence of its clearing evidence. Filters exempting a kind cite the exact spec sentence and are no wider than it. Check key uniqueness on every normative table before briefing.
- **Track unproduced inputs (`unproduced=<N>`):** Never report full acceptance while any declared verifier input lacks a wired producer. Derive `unproduced` from the single authoritative fed-table list. Ship rule families atomically (producers + goldens + wiring).
- **Host code fails closed and decides nothing:** User-level errors are decided by declarative rules, not imperative host code. Interim host checks only fail closed, are disclosed in reply honesty lines, and sit on an explicit conversion list.
- **Generated payloads stay separate & verified:** Never place hand-edited files in generator-wiped directories. Keep design-side generators out of the runtime repo; transfer large generated payloads via manifest-verified (`sha256sum -c`) couriers; verify via semantic back-translation + full golden suite + `stats.txt` zero-unmapped audit.
- **Laws ratchet:** Every escaped bug or process slip becomes a written rule or mechanical verifier the same day. When a mistake class repeats (2nd/3rd occurrence), upgrade from a verbal reminder to an automated gate/hook.

---

## 12. Self-use (dogfooding)

Whenever a language or system-surface feature lands (a new construct, invariant check, capability, or refinement), every unit the project owns in that surface (core/standard libraries, self-hosted sources) is updated to use it where it strengthens invariants. Queue this self-use task at acceptance right after the feature lands: the project applies its own guarantees to itself first.

---

## 13. Escalation: no task stays unsolved past two tries

- **Two-try cap per approach:** The same approach (fix, probe, parse, mutant, test, perf fix) may fail at most TWICE. The third try MUST change something real: escalate to a stronger coder tier with the same brief, OR redesign at the highest designer tier from fresh measurements. Never a third try with the same tier and same design.
- **Count tries explicitly:** Track attempts in the handoff (`task: try 1 failed because X; try 2 failed because Y`) and escalate immediately without asking the owner. A stronger coder never replaces measurement: probe/profile first.
- **Three consecutive failed fixes:** Stop and question the architecture.
- **Debug by instrument, not theory:** Minimal repro smaller than the goal -> isolate one variable with a probe table -> trace with IDs -> falsify hypothesis with a prototype and revert it. Fix the violated invariant at its producer; a real fix is small and deletes workarounds.

---

## 14. Audits and joint soundness protocol

- **Adversarial triage:** Every audit finding is a claim. Reproduce it on current code (via read-only `PROBE` when dynamic) with armed controls. Ask: *does it block or corrupt the critical path?*
  - **P0 (soundness / fail-open / corrupts path):** Act immediately — land a tiny fail-closed stop if needed, then co-design the full fix.
  - **P1 / P2 (non-blocking):** Queue as a rider on the next brief touching that file/phase. Never let non-P0 findings derail the critical path.
  - Reply to the auditor with `verified`, `refuted`, or `deferred` and exact changes made. No promises.
- **Mandatory post-landing commit verification gate:** Notify `@audit [verify-commit] <hash> <ID> (ticket <id>, brief <path>)` on every landed commit. Disjoint lanes keep running; dependent work does not stack on a P0-flagged commit until `@audit [verify-result] <hash> <ID>: CLEAN`. Keep a periodic sweep as backstop for cross-commit, doc, handoff, tracker, and cumulative perf drift. Track `LAST_AUDITED_COMMIT` watermark and monotonic finding IDs (`C<n>`).
- **Five audit bars:** (1) Specifications; (2) Core tenets; (3) Rulings ledger; (4) Fundamentals (type-enforcement, oracle, negative-control laws); (5) Correctness & Anti-Toy / Anti-Dead-Code gate (no unused work, no toys, no duplicate helpers, no isolated components without a scheduled reader).
- **Joint soundness protocol:** Design and auditor collaborate directly on P0 soundness bugs: inspect real diff/code against the five bars, isolate the broken invariant at its producer, enforce it in types, arm a minimal failing negative test + compiling mutant, review the fix brief together before dispatch, and close via `[verify-commit]` -> `[verify-result]`.
- **Peer claims stay claims:** Independently verify commit hashes, disk state, and test outputs before acting.

---

## 15. Tracker, metrics, and handoff discipline

- **Every task is a tracked ticket:** Plan at least the next 4 critical-path tasks ahead: parent epic, `blocks` edges ONLY where a later task genuinely reads an earlier task's output (phantom edges block starts), planned Fibonacci weight label, planned cycle length, and forecast delivery time.
- **Same-turn updates:** Update the tracker in the same turn as EVERY state change (sent, reported, accepted, failed, split, ruled, queued, re-planned). Never overwrite the planned length (it is the baseline estimate).
- **Per-stage effort reporting at acceptance:** Submit one report per stage with its own consistent agent name and ONLY its own minutes (trackers sum minutes across reports; never double-report a stage):
  - Implementation stage (`impl-agent <model>/<effort>`): actual minutes, attempts, tests pass/fail, actual diff weight (`<=30 -> 1`, `<=80 -> 2`, `<=150 -> 3`, `<=300 -> 5`, `<=600 -> 8`, `<=1200 -> 13`, `>1200 -> 21`), complexity (1–5), lane capacity = 1.
  - Perf stage (`perf-agent <model>/<effort>`): perf minutes only (omit capacity so total capacity is not inflated).
  - Design stage (`design <model>`): remaining cycle minutes, findings (commit, perf deltas, rulings, estimate vs. actual, own mistakes), capacity = 1.
  - Omit cycle minutes when the gap contains an outage or design pause; omit unknown fields rather than guessing zero. Report failures and gate misses candidly.
- **Read-back before closing:** Read a ticket's title back before commenting on or closing it.
- **Three-place dispatch tracking:** Record every dispatched task in the same turn in: (1) handoff (`DOING`: task, ticket, workspace, step, brief SHA-256), (2) lane ledger, and (3) issue tracker.
- **Durable docs & mistake ledger:** After every acceptance, correction, or slip, update handoff (short, overwritten, with exact next command), state ledger (prepended), lane ledger, rulings, perf ledger, queue, and commit docs in the same turn. Record own mistakes immediately as `what happened -> rule` and count recurrences to trigger automated gates.
- **Freeze verified insights as playbooks:** A verified procedure saved as a playbook lets future runs drop a model tier.

---

## 16. Implementer fundamentals (inlined into briefs)

- Build strictly the task text; invent no name, file, check, or step. On any gap: stop and ask `@design` one precise question with exact command and output (no options or proposals).
- Failing check or mismatched value: stop immediately, change nothing, report verbatim. Never alter an expected value or pick another command.
- Two failed fix attempts -> stop and report both with commands and outputs; never attempt a third.
- Hard 10-minute cap -> stop and report done, not done, and exact blocker.
- Strict path confinement: work only inside the named lane path and explicit read-only paths; never list parent directories.
- Zero VCS commands in worker agents (dispatcher runs read-only status/diff checks only; design commits/lands).
- Foreground builds only, one at a time (never background builds). Every command runs under `timeout` (<= 120 s) and a memory cap (except sanitizers). Kill only by captured `$!`. Never `sleep`-poll.
- Never claim done without verbatim oracle output, mutant FAIL + clean-restore SHA proof, and perf gate lines in the same <= 25-line report.
- Ignore context-limit warnings in hooks; write implementer notes only to implementer's own handoff/state files.

---

## 17. Honesty and recovery

- Report plainly: `passed`, `failed` (quote exact error), or `skipped`. No hedging, no implied wins.
- Report honest numbers verbatim, including regressions — an honest negative result ends a dead path early.
- Record own errors the moment they occur with the preventing rule; hiding an error is the worst failure.
- Reply lines state honestly what the system actually executed (`steps=...`, `unproduced=<n>`, interim failures) — never a silent success.
- "Vanished" files mean forensics first (`ls`, VCS status/log, `find`), never recreation.
- Dead agent != lost work: inspect disk and saved snapshots first; salvage and verify beat blind redo.
- Doc-compression agents hedge toward bloat: enforce a hard byte budget as a gate. Critic agents over-flag: spot-check before paying patch rounds.
- Code is disposable: a 1-minute rewrite from a clear spec beats an hour debugging tangled old attempts.
