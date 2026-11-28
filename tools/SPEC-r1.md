# tools/vic rung 1: statusline + hook guard + hook ledger

Workspace: /run/user/1000/jj-ws/vix/tools-vic (a jj workspace of ~/hk/vix). Work ONLY here. NEVER run jj or git.

## goal
Rust bin `vic` in a cargo workspace at `tools/` (root `tools/Cargo.toml`, crate `tools/vic/`). Rung 1 = 3 subcommands that replace 3 hot bash scripts with SAME behavior, faster startup:

| subcmd | replaces (read it fully first) | stdin | contract |
|---|---|---|---|
| `vic statusline` | modules/vic/ai/_scripts/statusline.sh | CC statusline JSON | one line on stdout, byte-identical to bash |
| `vic hook guard` | modules/vic/ai/vic/hooks/bash-guard.sh | PreToolUse JSON | exit 0 silent, or exit 2 + same stderr text |
| `vic hook ledger` | modules/vic/ai/vic/hooks/cmd-ledger.sh | PostToolUse JSON | append same JSON line to same file; zero stdout; fail-open exit 0 |

Out of scope: Nix packaging, settings.json/hooks wiring, other scripts, deleting the bash scripts. statusline keeps calling the external `vic-telemetry` and `vic-pm` exactly as the bash does (subprocess) — do NOT port them.

## toolchain
`timeout 600 systemd-run --user --scope -q -p MemoryMax=8G nix-shell -p cargo rustc clippy rustfmt --run '<cmd>'`. No other way. Every command under `timeout`.

## deps (approved, nothing else)
serde + serde_json, regex, lexopt. Prefer std where it is enough (time math: use std; ISO dates for `resets_at`: parse by hand or keep a tiny fn — no chrono).

## rust law (reject on any)
- no unwrap/expect/panic!/unreachable!/todo!/unsafe outside #[cfg(test)]. typed error enum, propagate Result.
- `cargo clippy --all-targets -- -D warnings` = 0 warnings. no #[allow].
- invalid state unrepresentable: parse stdin into typed structs (serde), newtypes where a bare string/number could be mixed up (e.g. CtxPct, ProjectKey).
- private by default. small modules: one per subcmd + shared (paths, transcript ctx).
- each unit test < 1s.

## oracle (the judge, not prose)
Write `tools/vic/tests/parity.sh` (bash) that runs bash script and `target/release/vic` on the SAME input and diffs:
1. guard: feed every command in `/run/user/1000/jj-ws/vix/bash-corpus.txt` (36693 real agent commands, one per line... NOTE lines may be fragments of multi-line commands; that is fine, treat each line as one command) as `{"tool_input":{"command":<line>}}`. Compare exit code + stderr for each. Report: total, mismatches (must be 0), and count of exit-2 refusals per reason (must be >0 for pkill-f, pgrep-f loop, uncapped nix — if the corpus lacks one, add a synthetic line; that is the armed control).
2. ledger: with HOME and CLAUDE_PROJECT_DIR set to temp dirs, run both on 20 fixture payloads (stdout long/short, stderr, missing fields, tool_response as string). Compare written files ignoring only the `ts` field. Show 1 written line.
3. statusline: fixture HOME with a fake `~/.headroom/subscription_state.json`, a fake transcript (last assistant usage row), and PATH stubs for `vic-telemetry`/`vic-pm` that print fixed text. Run both within the same second; byte-compare. Cover: no transcript, ctx 70/85 color bands, missing headroom file, cost absent.
Negative control: parity.sh must FAIL when you change one byte of rust output (show this once, then revert).

## also report
- startup: avg ms over 50 runs, bash vs rust, for each subcmd (same harness style: date +%s%N loop).
- `cargo test` + `cargo clippy` output tail, verbatim.
- file list + line counts.

## checkpoints
After each subcmd passes parity, append 1 line to `tools/PROGRESS.md` (what passed, numbers). Bad network: disk survives, context does not.

## stop rules
- bash behavior unclear or seems buggy: copy it EXACTLY, note it in PROGRESS.md under "bash quirks". Do not fix behavior in rung 1.
- 3 failed attempts at the same thing: stop, write the blocker to PROGRESS.md, report.
