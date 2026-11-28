# tool traps · fix (harvested 2026-10-21)

## jj
- land agent ws from default ws -> EMPTY commits (ws never snapshotted) · `jj st` INSIDE ws, check `jj diff -r @ --stat` non-empty, then land · n=5
- `jj workspace forget` before snapshot abandons work · snapshot first; recover via `jj op restore` + cp from ws dir · n=3
- `jj describe -R <sibling ws>` does not snapshot it -> empty commit · run jj inside that ws dir · n=2
- `jj abandon @` after edits drops them · `jj st` + `jj diff` first; recover `jj op restore <op>` · n=1
- main moves between sessions; stale base lands reverts · `jj log main` + rebase onto tip, verify diff stat (reverts = stale) · n=3
- `jj st` then land wrapper on stale ref = no-op · re-run rebase first · n=1
- stray `jj status` in ws mid-rung gave empty snapshot · never run jj in a working agent ws · n=2
- `jj workspace add` bases ws on @- not @ · pass explicit -r · n=1
- `jj workspace update-stale` after parent rewrite -> fresh empty @, edits in sibling · check files() revset before update-stale/rm · n=1
- `jj squash` opens $EDITOR, hangs · `JJ_EDITOR=true` + `--use-destination-message` · n=1
- workspace add fails: immutable_heads() refs missing main@origin · per-cmd `--config 'revset-aliases."immutable_heads()"="none()"'` · n=1
- jj chokes on target/ artifacts · add `/target` to .gitignore · n=1
- global git ignore `AGENT*` hides AGENTS.md · `jj file track --include-ignored` · n=1
- `git init` inside jj ws (git banned) · never; check the repo root first · n=1
- bench harness hardcoded stale ws path -> rc=1 every run · derive paths, never hardcode ws · n=1

## git
- worktree branches from last commit, not dirty tree · commit base before spawn · n=2
- `git grep -lin` parsed as `--lin`, error on stderr hidden by pipe · write stdout+stderr to files, read rc · n=1

## shell (fish/bash)
- Bash tool = bash, not fish; fish `set`/`$status`/`and` fail (exit 127) · write specs for bash · n=4
- fish eats $?; background cmds die silently · no POSIX-isms in fish lines; capture rc to file · n=2
- piped exit status hidden; empty filtered output read as zero · capture to file, read $? unpiped · n=2
- non-ASCII grep pattern errors, masked by `|| echo` -> false zero · no `|| echo` masks; check rc · n=1
- `pkill -f` self-matches own cmdline (exit 144); `pgrep -a br` matches dbus-broker · use `-x`; prove empty w/ none running · n=2
- `pkill -f name.*port` misses when port in env not argv · kill by pid/port · n=1
- background proc in one Bash call dies · `setsid` + `disown` · n=1
- piping gate output to tail loses data · tee to file · n=2
- `rg` w/o -L misses symlinked skill files · `rg -L`; `-uu` in ignored ws · n=3
- server serves data only from right cwd -> 503 false FAIL · `env -C <repo>`; pre-check data endpoint before judging UI · n=1
- stale process/binary looks like failed fix · compare process start time vs artifact · n=2
- deploy green != live · compare running build id to new artifact · n=1

## eval / build tools
- unit-test runner runs ONLY tests matching its naming rule; else silent 0/0 · prefix tests; positive control · n=2
- diverging eval hangs run · `timeout 2` per eval probe · n=2
- `f == f` on function values differs per evaluator · never use `==` on fn values as evidence · n=3
- the evaluator try-catch catches only throw+assert · don't rely on it for other errors · n=1
- deep-force first error follows intern order · error text not stable oracle · n=2
- `<tool> update foo` warns, exits 0, no change · check lock diff for revision lines · n=1
- CLI output strings differ by version · record the tool version w/ claim · n=1
- bare host prefix in an allowlist admits everything on that host · run a must-forbid control · n=1
- jj ws (no .git) breaks git-based source URLs · use a `path:` URL; enable the experimental feature flag when needed · n=1
- unpinned runner via remote ref; short timeout breaks under load · pin + generous timeout · n=1
- scrutinee referenced inside own dispatch arms / arity bug binds wrong arm silently · test each arm · n=1
- compiler/linter not in PATH · fetch it via an ad-hoc shell for the one command · n=4

## build / test runner
- workspace-wide test run silently skips packages not in members · assert per-package "running N tests" · n=2
- cp worktree root manifest = lossy · append member w/ controlled edit · n=2
- no formatter/linter in env · warnings-as-errors build flag · n=2
- no gdb · env-gated eprintln probes · n=1
- Stdio::piped + try_wait w/o drain = 64KB hang · file-backed stdout/stderr · n=2
- RTK reformats build output · ground-truth raw result · n=1
- whole-run abort/OOM · check ulimit, -j1, per-test isolation before blaming engine · n=2
- tallies across different ulimit/budget configs not comparable · same config or no compare · n=1
- runs: `ulimit -v 8388608; timeout <s>`; hangs were compute loops not memory (0 kills at 8GiB) · n=3
- line anchors shift every rung · locate sites by symbol · n=1

## br
- `br --description`/`--description-file` REPLACE body · read, append, write, verify · n=1
- line-count guard on body replace refuses short / passes truncated · compare with cmp + bytes · n=1

## codegraph / index
- fast/moderate index modes skip docs/scripts/tools/bin/build · full mode · n=1
- zero callers != dead code in dynamic-dispatch code (attrset-mediated calls) · cross-check grep · n=1

## harness / MCP / subagent
- MCP tools deferred: ToolSearch select before call · n=1
- message to working agent lands only at its next tool use; no preempt · n=1
- advice routing around permission classifier is unsafe · never teach bypass · n=1
- agent died on socket/ECONNRESET (367 tool uses, ~45 min) · short rungs, write disk early, salvage+verify · n=3
- single-process host w/ N agent terminals: one segfault kills fleet · split coordinator from workers · n=1
- first 429: pause whole fleet; per-agent idle-kill timer · n=1
- WebFetch strips script tags · curl raw to read client JS · n=1
- escaped apostrophe breaks JS workflow string · avoid in notes · n=1
- LSP hangs · wrap every call in `timeout 20` · n=1
- CSS `1fr` track blows to min-content · `minmax(0, 1fr)` · n=1
- Elm let-bound fns monomorphic; no 4-tuples · top-level helper; records · n=1
- agent jj workspaces left behind · after land: jj -R <ws-dir> st, jj workspace forget <name>, rm -rf <ws-dir>; ws live under $XDG_RUNTIME_DIR/jj-ws (wiped on reboot)

## quipu (measured 2026-10-28, v0.16.2; table: skill vic "QUIPU STORE = WHAT WORKS")
- `quipu_search_nodes` returns 0 even for an exact known label (`ledger:<proj>/mistake/git-init-in-ws`) · read with `quipu_ask` or `quipu_query` label prefix; 0 = broken instrument · n=2
- `quipu_search_facts` times out (30 s) on any text · never use it to verify an edge; `quipu_ask references_to` / `entity_facts` · n=2
- `quipu_search` / `quipu_hybrid_search` error "no embedding provider configured"; keyword mode disabled · do not read the error as "no match" · n=1
- `quipu_explain` not served (needs the `owl` build feature, off) though the server allowlists it · use `quipu_ask entity_facts` + the episode `source` · n=1
- `quipu_context` returns full episode bodies · pass `max_entities` <= 3; read `summary.truncated.more_available` · n=2
- store has 0 SHACL shapes loaded: knot/episode writes are not validated · pre-check with `quipu_validate` + inline shape (dry run, writes nothing) · n=1
- telemetry hook rows: `failed=1` on every row (474 with outcome `done`), `tier` stored as JSON `{"level": …}` · fail% from `a:outcome`, not `a:failed` · n=1
- ledger episodes carry 1 edge (`rdf:type`): `quipu_impact` / `references_to` find nothing from them · pass `edges` on every episode · n=1
- Proof-assistant simp: `simp only [f]` unfolds a NON-recursive match def on a variable into a match (not only on ctors); use the equation lemmas for ctor-only rewriting. A literal match arm then gives hyp c = t[c] and simp_all loops. maxRecDepth is a runtime exception: try/first never catch it, so one looping alternative kills every later alternative in a tactic cascade; raising the limit does not fix it. · 2026-11-04
- Proof-assistant macro hygiene: every lemma name a tactic macro uses must be defined ABOVE the macro, else the unknown ident inside try/first fails silently and the whole alt is skipped. Recursive (partial_fixpoint) defs never go in simp fact lists (infinite unfold): rewrite once. Some tactics (pick_goal) are library-only; core has rotate_left k. · 2026-11-04
- Proof-assistant slow-build bisect: cut the generated file at the failing theorem + namespace end, run the checker on the cut (43s vs 4min gate), 3-5 variants in parallel under a memory cap; find simp loops with set_option maxRecDepth 300 + trace.Meta.Tactic.simp.rewrite and tally rewrites with rg|sort|uniq -c. · 2026-11-04
- quipu_episode: edge source/target must be a NODE name w/ safe IRI path (no ':'); episode name 'ledger:...' as edge endpoint fails 'not a safe relative IRI path' · add slug node (proj-thing) + link it · n=1 · 2026-11-06
- paper fetch: ACM DL, Microsoft Research, Elsevier, CMU course pages send HTML to curl · check first bytes = %PDF · arXiv/author/university pages work · no file, no pdftotext in PATH: nix-shell -p poppler-utils --run 'pdftotext -layout x.pdf x.txt' · n=1 · 2026-11-06
- srs: AGENTS.md + CLAUDE.md are gitignored (.gitignore:3-4 AGENTS* CLAUDE*): edits live on disk only; jj commit of them = EMPTY commit (oznv, ouzz) · never commit them; check jj log -r @- --name-only after every commit · n=2 · 2026-11-06
- srs: main bookmark moves onto each new jj commit and main@origin follows (pushed to github, pusher unknown); a commit is immutable right after jj commit · never commit a placeholder message to fill later; write the final message at commit time · n=1 · 2026-11-06
- jj: a landing that rewrites parents strands unsnapshotted edits in OTHER lane workspaces (snx session 3: 4 ws stale). Landing scripts must run 'jj st' inside every live ws of the repo before rebasing/moving main and refuse on failure; recover stranded edits as patches from disk backups, never blanket file copies. · 2026-11-10
- perf sizing: a -fno-inline/-O1 callgrind profile overstates inlined helpers (snx kwtok: Str.eq '6.8%' was 0.43% in the release build). Noinline profiles locate code; lever sizes come only from release (LTO/inlined) builds via stub or call-twice deltas. · 2026-11-10
- beads: ids do not follow lane numbers (K6 = vic-kpev.7, not .6). Read the bead title back (br list --all | grep '<id> ') before every comment/close; keep an id map in the handoff note. · 2026-11-10
- CORRECTION to the stale-workspace lesson: lost lane work in snx session 3 was NOT caused by unsnapshotted ws under a parent rewrite (armed scratch test: edits survive). Cause: concurrent jj writers in one repo (supervisor jj calls racing a background landing) made DIVERGENT commits; update-stale checked out the wrong twin. Rule: one jj writer per repo (flock shared with the landing script); refuse to land if jj log -r 'divergent()' is non-empty; on 'lost' work find the divergent twin first. · 2026-11-10
- jj landing: 'jj rebase -r @' on a lane that has a child lane moves the CHILD onto the lane's old parent (child then shows conflicts). Land parents before creating child lanes, or rebase with -s; land scripts must refuse a lane whose @ has descendants outside main. · 2026-11-10
- jj guard revsets: 'divergent() & ::@' matches old divergent twins already in main's history (36 hits in srs) and blocks every landing; scope it to the lane: 'divergent() & (bookmarks(exact:"main")..@)'. Arm both ways: old revset hits, new revset 0 on a clean lane, and a positive control (a real twin) still hits. · 2026-11-10
- -fsanitize=function is inert under zig cc (armed fn-pointer type mismatch: exit 0, no report; -fsanitize=undefined is live). Calls through a wrongly typed function pointer need an IR-level check (vtable slot prototype == call prototype) plus a value oracle. · 2026-11-10
- bench binaries built from the default ws measured an old commit (snx e7f5447 vs main d9e4967); build from a ws at the exact commit, record commit id with every number · 2026-11-10
- quipu_episode edges: a 'ledger:<proj>/...' episode name is not a valid edge endpoint (colon refused as IRI path); add a plain-slug node (e.g. brain-verdicts-2026-11-10) and hang edges on it · 2026-11-10
- measurement tooling kept only in a tmpfs jj ws dies on reboot (snx census lost, re-census = rebuild); land it behind a compile-time define with release byte-identical as control · 2026-11-10
- measurement builds against a moving dependency path (~/hk/srs-main) changed under the lane: two same-source snx builds differed by 37 KB because srs landed between them; pin deps to a ws at a fixed commit, record both ids · 2026-11-10
- brief export loop 'cd $B/old && for f ...; do jj file show ... > $f' ran with cwd = repo when cd failed: truncated 32 tracked files, then a landing snapshot recorded 24,819 deletions; briefs write absolute paths only, cd X || exit 1 · 2026-11-10
- srs rt hot path: making the per-append buffer function non-inline turned a win into +0.36% on corpus-tests; keep an inline fast path, noinline only the slow path · 2026-11-10
- Before ruling a checker hole from a failing test, trace the entry the test oracle calls vs the entry the compiler runs (srs: tests used Ty.check on raw decls, s2c runs Tl.expand first); a test-only entry can bypass a pass. · 2026-11-10
- land-srs.sh moved srs main before its snx gate: 'landed but snx red' was a reachable state. A landing script must run every gate on the candidate commit, then move main once. Never edit a bash script while a running process reads it. · 2026-11-10
- Before ruling that code must cover an arm/mode, prove the arm reachable for that feature; a mutant that survives on the arm marks dead code (srs xalloc VTable arm: prelude always installs Srs.Arena, so Inline only). · 2026-11-10
- Agent tool can be DEFERRED: keyword ToolSearch 'Agent spawn subagent' missed it; load with ToolSearch select:Agent,ListAgents before saying spawn is impossible (brain 2026-11-11 told vic it could not spawn hands). · 2026-11-11
- Spec adding an enum case (srs Ty.Clash, El.*): rg EVERY exhaustive match of that enum incl. tests/ (tests/s2/types.srs TT.show missed in A1b spec = gate FAIL s2c_types). A mutant spec must name every independent path to the error (Mut checked in Ty.needMut AND Eff.expr: single drop survives). · 2026-11-11
- Equivalence oracle vs a quadratic reference (C lcLine scans from byte 0 per call): every-offset compare on big files blows the 10-min agent cap (hands2 linetab turn ~21 min). Spec must cap reference cost: stride or size limit stated up front. · 2026-11-11
- Parallel srs lanes that each add a case to the same enum (Ty.Clash) + TT.show conflict textually on rebase (A1b PutData vs patfix NestedPattern after LenUnnamed). Pre-rebase every queued lane onto new main by hand and keep both arms; never rely on the land script to notice non-seed conflicts. · 2026-11-11
- land-srs3 needs a childless @: a lane that has other lanes stacked on it dies 'LAND-DONE has-children'. Land each lane from its own childless duplicate on current main (jj duplicate onto main), keep the stack for development only. · 2026-11-11
- srs landing: land-srs3 describes and rebases @ and needs it childless. Never stack other lanes on a commit you are about to land (has-children abort, I32 2026-11-11). Land from a childless duplicate (jjw duplicate <commit> -d main, edit it in its own ws); rebase the stack onto landed main after. · 2026-11-11
- srs byte-class tests: compare chains cost +174M on nixos-server vs 256-char Str literal tables (Str.at(table, c)); always table loads. srs byte loops (Str.at total check per byte, no unroll) lose to C nx_run: port of hot scanners waits for proved-index Str loads + rodata tables in srs. · 2026-11-11
- Editing a commit in place (jj edit/squash into a parent) makes every ws built on its descendants stale; land scripts that snapshot all ws then die 'snapshot-failed'. Announce in-place edits to ws owners first; owners back up, then update-stale. · 2026-11-11
- jj: editing a commit in place (jjw edit <mid-stack commit>) rewrites every descendant, so every other ws on those descendants turns stale and land-srs3's snapshot-all step fails (snapshot-failed: <ws>). Announce in-place edits to the ws owners first, or add a new commit on top instead (2026-11-11, 3b cneg fix). · 2026-11-11
- Agents 'mirror' a compiler change into the hand-C runtime twin (rt_str_at in srs_rt.c) by habit: that is writing C by hand. Brief must say: change only compiler-emitted C; hand C runtime files are read-only debt. · 2026-11-11
- tools: a path to a tool recorded in a file (perfpath) can be GC'd from the nix store; scripts then fail silently and reuse a stale -o output file (identical bogus numbers, 2026-11-11 perf). Every measurement script must fail loudly if the tool is missing and must rm its output file before each run. · 2026-11-11
- srs lanes that add a Ty.Clash/El/Ast case must run tests/run.sh's s2c_types step (tests/s2/types.srs TT.show is an exhaustive match) before reporting: missed twice on 2026-11-11 (A1b PutData, 3b LibcOutsideHandler), the 2nd made a land gate-red. · 2026-11-11
- srs land gate includes the corpus fragment ratchet (bench/corpus/s2 + lib): a rule that rejects code the frozen corpus contains (Srs.* reserved names) zeroes the ratchet counts (stmt-expr 16490 -> 0) = gate-red. Run tests/run.sh's corpus section on the land dup before launch, not only the tests/s2 component loop. · 2026-11-11
- Chained land waiters that read a REUSED land .out file exit on a stale non-ok LAND-DONE line from an earlier run (opesc waiter died twice). Each relaunch writes a NEW out file name (landX2.out) and the next waiter is re-pointed, or waiters match only lines appended after they start. · 2026-11-11
- Chained land waiters cascade: one PREV-NOT-OK (e.g. land script snapshot-failed on a stale ws of an already-landed lane) propagates down the whole queue. Before each land: forget or refresh landed lanes' ws (snapshot-all land scripts die on stale ws); waiters should treat PREV-NOT-OK by waiting for a fresh LAND-DONE ok instead of exiting. · 2026-11-11
- br comments add "..." with backticks inside double quotes runs them as shell commands (hands2's vic-6z7p.36 comment lost its C text). Put bead comment text in a file and pass it with single quotes or a here-file, never backticks in double quotes. · 2026-11-11
- srs main trap: revset main resolves to main@origin (stale 4f32365); real local main = bookmarks(exact:"main"). Base every ws on bookmarks(exact:"main"). · 2026-11-11
- fault oracles on shared host: THP fallback swings faults 10pct+ run to run (thp_fault_fallback 444-474/run, each up to 512 4K faults). Every fault oracle: grep thp_fault /proc/vmstat before+after each run, interleave, report raw faults + thp deltas; brk peak and maxrss are the stable metrics. · 2026-11-11
- perf call chains at perf_event_paranoid=2: plain -g/--call-graph fails (Failure to open any events) because it asks for kernel callchains. Add --user-callchains: perf record -e page-faults:u -c 1 --call-graph fp --user-callchains works (dwarf too). Not blocked. · 2026-11-11
- snx/iets benches: a hands agent shell can carry a hard ulimit -v (run1.sh warns 'cannot modify limit'); iets then dies 'mmap failed: OutOfMemory' after ~20 s while snx runs fine. Check 'ulimit -Hv' = unlimited in the brief before any iets number; never diagnose the host from that abort (2026-11-11 r1split). · 2026-11-11
- perf/memory lever: build a <=30 min ablation STUB first (skip/free the suspect allocation) and measure the WHOLE workload (instr, RSS, faults); no stub ceiling >= bar => no real code. First-touch fault attribution names who touched a page first, not who holds the peak (freed pages get reused): rank causes by live bytes at the peak. Cost of skipping: snx A2 packed tokens, 1.5 h, hackage peak -18% but whole-run RSS 0% and +6.5% instr (ledger:snx/mistake/first-touch-misattribution-a2-2026-11-11) · 2026-11-11
