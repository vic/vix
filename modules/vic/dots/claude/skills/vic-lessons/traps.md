# tool traps · fix (harvested 2026-10-21)

## jj
- land agent ws from default ws -> EMPTY commits (ws never snapshotted) · `jj st` INSIDE ws, check `jj diff -r @ --stat` non-empty, then land · n=5 · src:dnx3/discipline.md, genie/HANDOFF.md, quipu/ledger, denren/HANDOFF.md
- `jj workspace forget` before snapshot abandons work · snapshot first; recover via `jj op restore` + cp from ws dir · n=3 · src:denren/HANDOFF.md, quipu/ledger
- `jj describe -R <sibling ws>` does not snapshot it -> empty commit · run jj inside that ws dir · n=2 · src:dnx3/state.md, otro/HANDOFF.md
- `jj abandon @` after edits drops them · `jj st` + `jj diff` first; recover `jj op restore <op>` · n=1 · src:quipu/ledger
- main moves between sessions; stale base lands reverts · `jj log main` + rebase onto tip, verify diff stat (reverts = stale) · n=3 · src:viejo/state.md, otro/state.md, dnx/jj-land-dance.md
- `jj st` then land wrapper on stale ref = no-op · re-run rebase first · n=1 · src:dnx/jj-land-dance.md
- stray `jj status` in ws mid-rung gave empty snapshot · never run jj in a working agent ws · n=2 · src:viejo/state.md, otro/HANDOFF.md
- `jj workspace add` bases ws on @- not @ · pass explicit -r · n=1 · src:misc/state.md
- `jj workspace update-stale` after parent rewrite -> fresh empty @, edits in sibling · check files() revset before update-stale/rm · n=1 · src:misc/state.md
- `jj squash` opens $EDITOR, hangs · `JJ_EDITOR=true` + `--use-destination-message` · n=1 · src:rev/state.md
- workspace add fails: immutable_heads() refs missing main@origin · per-cmd `--config 'revset-aliases."immutable_heads()"="none()"'` · n=1 · src:quipu/ledger
- jj chokes on target/ artifacts · add `/target` to .gitignore · n=1 · src:denren/state.md
- global git ignore `AGENT*` hides AGENTS.md · `jj file track --include-ignored` · n=1 · src:misc/state.md
- `git init` inside jj ws (git banned) · never; check rev-parse · n=1 · src:quipu/ledger
- bench harness hardcoded stale ws path -> rc=1 every run · derive paths, never hardcode ws · n=1 · src:denren/HANDOFF.md

## git
- worktree branches from last commit, not dirty tree · commit base before spawn · n=2 · src:dnx3/discipline.md, otro/discipline.md
- `git grep -lin` parsed as `--lin`, error on stderr hidden by pipe · write stdout+stderr to files, read rc · n=1 · src:genie/Q12-traps-nix.md

## shell (fish/bash)
- Bash tool = bash, not fish; fish `set`/`$status`/`and` fail (exit 127) · write specs for bash · n=4 · src:genie/HANDOFF.md, misc/state.md, quipu/ledger, vic-history/memory
- fish eats $?; background cmds die silently · no POSIX-isms in fish lines; capture rc to file · n=2 · src:viejo/state.md, otro/state.md
- piped exit status hidden; empty filtered output read as zero · capture to file, read $? unpiped · n=2 · src:quipu/ledger, genie/Q12-traps-nix.md
- non-ASCII grep pattern errors, masked by `|| echo` -> false zero · no `|| echo` masks; check rc · n=1 · src:misc/state.md
- `pkill -f` self-matches own cmdline (exit 144); `pgrep -a br` matches dbus-broker · use `-x`; prove empty w/ none running · n=2 · src:misc/state.md, genie/Q11-traps-harness.md
- `pkill -f name.*port` misses when port in env not argv · kill by pid/port · n=1 · src:rev/state.md
- background proc in one Bash call dies · `setsid` + `disown` · n=1 · src:rev/state.md
- piping gate output to tail loses data · tee to file · n=2 · src:misc/HANDOFF.md, vic-history/history.jsonl
- `rg` w/o -L misses symlinked skill files · `rg -L`; `-uu` in ignored ws · n=3 · src:quipu/ledger, denren/HANDOFF.md, vic-history/memory
- server serves data only from right cwd -> 503 false FAIL · `env -C <repo>`; pre-check data endpoint before judging UI · n=1 · src:rev/lessons.md
- stale process/binary looks like failed fix · compare process start time vs artifact · n=2 · src:genie/Q11-traps-harness.md, rev/state.md
- deploy green != live · compare running build id to new artifact · n=1 · src:genie/Q12-traps-nix.md

## nix
- nix-unit runs ONLY `test*` attrs; else silent 0/0 · prefix tests; positive control · n=2 · src:viejo/state.md, otro/HANDOFF.md
- diverging eval hangs run · `timeout 2` per instantiate probe · n=2 · src:pnx/MEASURE-PLAN.md, dnx3/discipline.md
- `f == f` false on CppNix, true on Lix; `{v=f;}=={v=f;}` true · never use `==` on fn values as evidence · n=3 · src:pnx/HANDOFF.md, genie/Q12-traps-nix.md, quipu/ledger
- `tryEval` catches only throw+assert · don't rely on it for other errors · n=1 · src:pnx/HANDOFF.md
- deepSeq first error follows intern order · error text not stable oracle · n=2 · src:pnx/HANDOFF.md, quipu/ledger
- `nix flake update foo` warns, exits 0, no change · check lock diff for rev lines · n=1 · src:genie/Q12-traps-nix.md
- CLI output strings differ by version · record `nix --version` w/ claim · n=1 · src:genie/Q12-traps-nix.md
- bare `github:` in allowed-uris admits everything github · run a must-forbid control · n=1 · src:quipu/ledger
- jj ws (no .git) breaks git flake URL · use `path:` URL; add `--extra-experimental-features pipe-operators` when needed · n=1 · src:misc/HANDOFF.md
- `nix run nixpkgs#nix-unit` unpinned; short timeout breaks under load · pin + generous timeout · n=1 · src:denren/review-v2-feedback.md
- scrutinee referenced inside own dispatch arms / arity bug binds wrong arm silently · test each arm · n=1 · src:dnx/track-nix-gate.md
- cargo/go/clippy not in PATH · `nix shell nixpkgs#cargo nixpkgs#rustc nixpkgs#gcc -c cargo ...` / `nix-shell -p go` · n=4 · src:pnx/HANDOFF.md, denren/state.md, misc/HANDOFF.md, viejo/state.md

## cargo / rust
- `cargo test --workspace` silently skips crates not in members · assert per-crate "running N tests" · n=2 · src:dnx3/discipline.md, otro/discipline.md
- cp worktree root Cargo.toml = lossy · append member w/ controlled edit · n=2 · src:dnx3/discipline.md, otro/discipline.md
- no rustfmt/clippy in env · `RUSTFLAGS=-Dwarnings` build · n=2 · src:viejo/state.md, otro/HANDOFF.md
- no gdb · env-gated eprintln probes · n=1 · src:viejo/state.md
- Stdio::piped + try_wait w/o drain = 64KB hang · file-backed stdout/stderr · n=2 · src:viejo/state.md, otro/state.md
- RTK reformats cargo output · ground-truth raw result · n=1 · src:dnx3/state.md
- whole-run abort/OOM · check ulimit, -j1, per-test isolation before blaming engine · n=2 · src:dnx/gate-triage.md, dnx3/discipline.md
- tallies across different ulimit/budget configs not comparable · same config or no compare · n=1 · src:dnx/gate-triage.md
- runs: `ulimit -v 8388608; timeout <s>`; hangs were compute loops not memory (0 kills at 8GiB) · n=3 · src:dnx/track-perf.md, dnx/track-soundness.md, dnx3/discipline.md
- line anchors shift every rung · locate sites by symbol · n=1 · src:otro/HANDOFF.md

## br
- `br --description`/`--description-file` REPLACE body · read, append, write, verify · n=1 · src:quipu/ledger
- line-count guard on body replace refuses short / passes truncated · compare with cmp + bytes · n=1 · src:genie/Q11-traps-harness.md

## codegraph / index
- fast/moderate index modes skip docs/scripts/tools/bin/build · full mode · n=1 · src:genie/Q11-traps-harness.md
- zero callers != dead code in Nix (attrset-mediated calls) · cross-check grep · n=1 · src:genie/Q11-traps-harness.md

## harness / MCP / subagent
- MCP tools deferred: ToolSearch select before call · n=1 · src:misc/verified-findings.md
- message to working agent lands only at its next tool use; no preempt · n=1 · src:genie/Q11-traps-harness.md
- advice routing around permission classifier is unsafe · never teach bypass · n=1 · src:genie/Q11-traps-harness.md
- agent died on socket/ECONNRESET (367 tool uses, ~45 min) · short rungs, write disk early, salvage+verify · n=3 · src:viejo/state.md, otro/state.md, misc/state.md
- single-process host w/ N agent terminals: one segfault kills fleet · split coordinator from workers · n=1 · src:misc/decision-memo.md
- first 429: pause whole fleet; per-agent idle-kill timer · n=1 · src:misc/decision-memo.md
- WebFetch strips script tags · curl raw to read client JS · n=1 · src:misc/state.md
- escaped apostrophe breaks JS workflow string · avoid in notes · n=1 · src:misc/state.md
- LSP hangs · wrap every call in `timeout 20` · n=1 · src:genie/Q12-traps-nix.md
- CSS `1fr` track blows to min-content · `minmax(0, 1fr)` · n=1 · src:rev/HANDOFF.md
- Elm let-bound fns monomorphic; no 4-tuples · top-level helper; records · n=1 · src:rev/state.md
- agent jj workspaces left behind · after land: jj -R <ws-dir> st, jj workspace forget <name>, rm -rf <ws-dir>; ws live under $XDG_RUNTIME_DIR/jj-ws (wiped on reboot) · src:vix/2026-10-21

## quipu (measured 2026-10-28, v0.16.2; table: skill vic "QUIPU STORE = WHAT WORKS")
- `quipu_search_nodes` returns 0 even for an exact known label (`ledger:vix/mistake/git-init-in-ws`) · read with `quipu_ask` or `quipu_query` label prefix; 0 = broken instrument · n=2 · src:quipu/live-2026-10-28, vix/vic SKILL.md
- `quipu_search_facts` times out (30 s) on any text · never use it to verify an edge; `quipu_ask references_to` / `entity_facts` · n=2 · src:quipu/live-2026-10-28
- `quipu_search` / `quipu_hybrid_search` error "no embedding provider configured"; keyword mode disabled · do not read the error as "no match" · n=1 · src:quipu/live-2026-10-28
- `quipu_explain` not served (needs the `owl` build feature, off) though `_quipu.nix` allowlists it · use `quipu_ask entity_facts` + the episode `source` · n=1 · src:quipu/src/mcp/definitions.rs:45
- `quipu_context` returns full episode bodies · pass `max_entities` <= 3; read `summary.truncated.more_available` · n=2 · src:quipu/live-2026-10-28, vix/vic SKILL.md
- store has 0 SHACL shapes loaded: knot/episode writes are not validated · pre-check with `quipu_validate` + inline shape (dry run, writes nothing) · n=1 · src:quipu/live-2026-10-28
- telemetry hook rows: `failed=1` on every row (474 with outcome `done`), `tier` stored as JSON `{"level": …}` · fail% from `a:outcome`, not `a:failed` · n=1 · src:quipu/live-2026-10-28, vix/bin/vic-telemetry:33,55
- ledger episodes carry 1 edge (`rdf:type`): `quipu_impact` / `references_to` find nothing from them · pass `edges` on every episode · n=1 · src:quipu/live-2026-10-28
