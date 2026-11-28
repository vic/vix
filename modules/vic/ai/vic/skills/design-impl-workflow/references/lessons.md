# Lessons (generic; each cost a round; "what happened -> rule")

## Briefs, rulings, and specs
- A brief contradicted a ruling written the same day (three times in one project) -> before staging, open EVERY cited ruling (including amendments) and verify each step's logic, not only counts.
- A designer re-staged an already-dispatched brief in place, changing its SHA-256 mid-flight -> NEVER re-stage a dispatched brief in place; version revisions as `<ID>-v2` with a new SHA-256 and explicit dispatch notice.
- A correction was sent by message only; the brief file kept the old text and the new code had no negative check -> write corrections into a new versioned brief file, re-stage with a new hash the same turn, and add a negative check for every new code path.
- A brief claimed "no existing fixture does X" without searching; an existing test failed mid-flight -> every absence claim cites the exact `rg` command, its zero output, AND an armed control finding a known item.
- Drafts used stale struct/enum/field spellings -> verify every symbol spelling against live headers before staging.
- A brief told worker subagents to invoke an external skill tool they did not possess -> inline the governing coding laws directly in `FIXED AGENT LINES` and point to the repo-local law file.
- Planner drafts leaked tracker CLI flags/DB paths into the ticket line and omitted the ticket ID on line 1 -> ticket line holds the plain ID only, always on line 1.
- A brief prescribed a `MAX` sentinel (or bare `bool`) conflating domain absence with OOM -> briefs specify closed typed outcomes (enum kind + payload) only.
- A brief used hand line ranges and a `FILES` line contradicting diff-stat -> anchor edits by exact text, never line numbers; verify `FILES` matches expected diff-stat before sending.
- An ad-hoc verification brief written from memory omitted CLI arguments and ran an unscoped `rg` hitting pre-existing matches -> copy exact command invocations and scoped paths from the lane briefs being verified.
- Planned a task as blocked by another with no real data dependency; the tracker refused to start it -> add `blocks` edges ONLY where the later task reads the earlier task's output.
- An interim guard was landed, then deleted one commit later by an already-planned task -> when the next task on the same interface is already known, brief the final form at once (exception: tiny P0 fail-closed stop closing an active soundness hole).
- A spec table keyed by one column mapped two source lines onto one key, making both owe forever -> verify key uniqueness of every normative table before briefing.
- A fixture violated the spec grammar (illegal clause placement, single-letter binder) -> probe every fixture with the real parser first; use full-word names.
- Asked the owner a spec question already answered in the docs -> mandatory full-spec search (grammar, rules, AND examples) before escalating.

## Soundness and fail-closed architecture
- A pipeline elaborated only 3 declaration kinds and silently skipped the rest -> maintain an explicit unit/AST-kind census and refuse every unmodeled kind unconditionally by structure until wired.
- Catching elaboration errors with `continue` without emitting a rejection silently accepted invalid units -> every non-infrastructure failure emits a structured rejection row and fails closed.
- A production driver left 4 target fields unset that only unit tests populated, silently disabling a soundness rule in production -> ban test-only plumbing; verify every input is populated on the production driver path (prefer per-unit arrays over global single-target fields).
- An emitter skipped emitting a required obligation row when a sub-lookup failed -> key obligations strictly on structural presence, never on the presence or formability of clearing evidence.
- A declarative verifier reported "accepted" while dozens of input tables had zero producers -> track `unproduced=<N>` automatically from the single authoritative fed-table list and never report full acceptance while `unproduced > 0`.
- A call or assertion credited its postcondition in the same scope where it checked its precondition -> evaluate owed preconditions in the pre-operation scope and credit established facts in a strictly nested child scope of subsequent nodes only.
- A kind filter dropped ALL tail calls when the spec exempted only direct tail self-calls -> every exemption filter cites the exact spec sentence and is no wider than it.
- A verdict cache key omitted callee contracts and served stale accepts after contract edits -> hash every verdict-relevant input including callee contracts/summaries.
- Dispatching a match by the first pattern's syntax accepted illegal wildcards over closed enums -> dispatch on value/type evidence; fail closed when evidence is missing.
- Bidirectional inference followed normalized/swapped operand storage order (`a > b` stored as `Less(b, a)`), causing unsound flow -> follow source order for bidirectional inference and side-effect ordering.
- Two row arrays backed by one shared formatting buffer silently aliased and corrupted the first array -> size formatted strings dynamically in dedicated/arena storage; never alias a shared static scratch buffer across calls.
- Precomputed arena slice capacity used an ad-hoc multiplier instead of the writer's exact traversal count, corrupting adjacent arena memory invisibly to ASan -> derive precomputed capacities from the exact same predicate/count the writer loop iterates.
- Fixed-size stack buffers for formatted symbols silently truncated valid large inputs -> size formatted text dynamically from its parts in the arena.
- A hand-edited file lived in a directory wiped by a code generator -> strictly separate generated directories from hand-written files; verify generated payloads via back-translation + full golden suite + zero-unmapped stats audit.
- Zero-length array backed by `NULL` risked UB/crash under branchless masked indexing -> back zero-length arrays with a valid aligned `static const` dummy sentinel.

## Mutants, oracles, and tests
- Mutants were left LIVE in a workspace three times (and once squashed into a commit) -> save clean pre-mutant snapshots (`mutant-save-<file>`), verify `sha256sum` clean restore AND run a mutant-residue `rg` scan before landing.
- Mutants that deleted a call/loop left variables or static helpers unused and broke `-Werror` (an 18-minute wasted run) -> mutate a condition, constant, argument, or string; verify `rg -Fc == 1` anchor first.
- A mutant reading uninitialized memory caused a fake kill -> verify every mutant is well-defined and fails for the intended semantic reason.
- A mutant on a helper survived while the product allocation site stayed wrong -> mutate the product site, never only a test-inspected helper.
- A sort-removal mutant survived because the test loader pre-sorted inputs; a length-bound mutant survived because the test closed the pipe early; an arena-offset mutant survived because fixtures used offset 0 -> arm fixtures adversarially (unsorted inputs, open pipes past bound, non-zero offsets).
- A bounds-check mutant survived because an earlier check already enforced the identical condition -> use surviving mutants to prune proven dead/redundant code.
- Predicted 6 failures, got 11: a dispatch mutant reroutes BOTH paths -> list checks from both paths; for early-step mutants, predict the full downstream cascade.
- Predicted multi-line free failure text that spanned lines -> predict failing check NAMES unless probed on a scratch copy.
- A closed-enum switch omitted `default:` -> add a compile-fail mutant deleting one `case` to prove `-Wswitch -Werror` actually fires.
- A test asserted a bug; the right fix broke it -> independently derive spec truth, write a numbered ruling, then update the test. Never blindly edit expectations to match code.
- A benchmark/integration fixture silently started rejecting early after a semantic change -> assert fixtures actually execute all intended stages (`rejects=0`, `steps=...`).
- A readback test ignored internal sharing and hid a sharing bug -> exercise shared structure explicitly.
- An unguarded subprocess spawn in a test hung the harness -> every spawned process gets a kill timer.
- Hand-computed indices in tests caused repeated off-by-one bugs -> derive index tables in comments and verify against a listing.
- A leak scan reported CLEAN with zero armed controls -> every zero-count scan needs an armed positive control proving it can fire.

## Performance, profiling, and ablation
- Blind perf tweaks without profiling failed 3 times in a row (+1.62% -> +3.76% -> +1.72%) -> on ANY perf gate miss, the ONLY permitted next action is profiling (`callgrind`/`perf record`/`-fstack-usage`) or controlled ablation.
- Adding a second call site to a hot per-node helper caused the compiler to stop inlining it (+2.8M–3.7% instr); moving a hot helper across translation units did the same -> keep hot cross-TU helpers `static inline` (`always_inline` where critical) in headers and gate with `nm` for zero out-of-line symbols.
- A +3.2% RSS gate miss on a wide/deep chain came from compiler inlining inflating recursive stack frames, exposing a P0 stack overflow at 4 MB -> chase synthetic RSS misses to the invariant; convert deep chain recursion to iteration and test under `ulimit -s 1024` + `-fstack-usage`.
- 15 consecutive commits each passed the +1% per-commit gate yet drifted +1.31% cumulatively -> run cumulative wave-end vs. wave-start perf audits.
- Stale or cross-lane perf baselines produced false misses and hid regressions -> compute bars strictly against same-host re-measured `LAND-VERIFY` main-tip baselines; record dependency commit SHAs on every perf-log row.
- Rows measured before the commit got tagged with the wrong commit -> commit first, then measure.
- Small multi-unit benchmarks hid an $O(N^2)$ lookup (0.2% impact) that consumed 91.7% of an 8,000-node wide unit -> benchmark BOTH realistic multi-unit trees AND adversarial wide/deep stress inputs.
- Pooling 2,000+ units into one global rule-engine solve triggered $O(U^3)$ cross-unit pairs (billions of rows, 20s timeout) -> split transaction-global rules from per-unit evaluation with summaries; count what the shallow layer feeds the deep layer first.
- Keeping scratch arenas alive across downstream evaluation pushed peak RSS over +2% and doubled wall time -> release ephemeral scratch arenas immediately before heavy downstream phases.
- Pre-filtering keyword matches by length alone regressed +5.2% on lowercase-heavy inputs due to length collisions -> pre-filter on length AND first byte (or first-byte bitset).
- A no-inline profile claimed a 6.8% cost that was 0.43% inlined; an old probe had hidden scaffold -> profiles locate, release-build ablations size; store probe setup with every number; revert optimizations with `< 2–5%` ROI.
- One extra linear pass + auxiliary array caused 3 consecutive gate misses (~47 instr/node) -> prefer single-pass top-down flow with minimal bounded back-patching.
- A cost accepted at +2% was proved 91–94% required new semantic work via step-by-step ablation -> accept only with controlled ablation evidence and a numbered ruling, never a post-hoc "per-output" waiver when baseline output was zero.
- Test-suite subprocesses skewed instruction counts and in-process opens inflated test cost -> use `perf stat --no-inherit` and track test-harness cost separately from product benchmarks.

## Process, parallel lanes, and VCS hygiene
- Cross-lane interactive squash merged 3 lanes while 2 still had unrestored mutants on disk -> land lanes linearly one commit at a time after SHA-256 clean-restore checks; never cross-lane squash dirty workspaces.
- Parallel lanes conflicted on shared test-count assertion lines even when `src/` files were disjoint -> enforce disjointness across BOTH `src/` AND `test/` count-assertion files; serialize tasks touching shared wiring or count files.
- A legacy sequential build caused all 4 parallel lanes to hit 300 s timeouts -> pause feature lanes to land priority infra fixes (`BUILD-FAST`), then rebase all lanes onto it.
- Chaining `jj st && jj new` over uncommitted implementer notes moved them to a side commit; `jj restore` wiped implementer memory -> `jj st` is a stop gate (never chained); never restore or edit another role's notes.
- A shell redirect `> perf-log.tsv` after a failed VCS command truncated the log to 0 bytes -> write to a temp file, chain `&&` with a row-count monotonicity check (`new >= old`), and atomically `mv`.
- `cmd | tail; echo EXIT=$?` reported `tail`'s exit code -> capture output to a file, then `echo EXIT=$?` immediately after the command.
- A shared static library was rebuilt while a peer audit build was linking it -> check `ps -ef` for active builds and notify peers before touching any shared artifact.
- Messaging a bare role name routed to a dead/stale session -> address peers by explicit session ID (`role [hexid]`) and clean up dead sockets/daemons on retirement.
- A persistent designer subagent swept all briefs and exhausted its context -> strict scope: one task, named briefs only, minimal edits, small outputs.
- A `perl` multi-line rewrite spliced into the wrong site and burned 25 minutes -> structured editor tools only for multi-line edits.
- A coding agent raced its own builds in the background -> foreground builds only, one at a time.
- A session wrote "done" for missing code, another wrote "not started" for finished code, and a dead agent left green code on disk -> verify every claim on disk (`ls`, `diff`, `sha256sum`); salvage and verify beat redo.
- Implementer sat idle 14 minutes while the next brief was written after acceptance -> pre-write, probe, and stage the next brief while the current lane runs.
- An hour-long stall repeated because mutant anchors were predicted and one blocked lane stopped the others -> read anchors on disk; keep up to 5 disjoint lanes busy.
- Counting recurrences of own slips (e.g., 3rd brief-vs-ruling slip) exposed systemic gaps -> log every own slip immediately as `what happened -> rule`, and upgrade repeated slips into automated hooks/verifiers.
- A "missing" directory had been moved by the owner -> forensics first, never recreate.
- Doc-compression agents hedged to 90–100% of source size -> enforce a hard byte budget as a gate.
- Critic agents over-flagged items already present -> spot-check before paying patch rounds.
- A fast local shortcut hid a system-dependent builtin and broke CI -> prove locally the same way CI proves it.

## Methods that worked
- Small oracle-gated ladder rungs, banked linearly before the next. Big-bang work dies.
- Two independent paths agreeing (differential oracle + `ddmin` shrinker) is the strongest oracle shape.
- Honesty clauses ("honest numbers verbatim if slower") yield honest negative results and instant pivots.
- Cheap/fast readers sweep large corpora into structured extractions; strong thinkers derive invariants and rulings.
- Freezing an expensive verified procedure as a playbook drops future runs by one model tier.
- Deterministic mechanical hooks/verifiers outside the LLM prompt loop convert ~80% prompt compliance into ~100% hard gates.
- An anchored law document keeps every citation alive through compression.
