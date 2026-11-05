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
