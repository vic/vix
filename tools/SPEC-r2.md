# tools/vic rung 2: nix package + hook wiring + jj enforcement

Workspace: given in the brief (jj workspace of ~/hk/vix). Work ONLY there. NEVER run jj or git.

## P
Agents get the r1 Rust hot path (guard 4.8 ms vs 33, ledger 6.7 vs 25, statusline 28 vs 110) and the harness enforces LOCAL REPO LAW (modules/vic/ai/vic/skills/workspace/SKILL.md) so agents cannot forget it.

## I
1. package: new `modules/packages/vic-tools.nix`, same aspect shape as modules/packages/vic-edge.nix (`at = yen.kinds.system; packages = { system, ... }: ...`). `vic-tools = pkgs.rustPlatform.buildRustPackage { pname = "vic-tools"; src = ../../tools; cargoLock.lockFile = ../../tools/Cargo.lock; ... }`. Result has `bin/vic`. Run the crate tests in checkPhase (default) — they are < 1 s.
2. new Rust behavior (tools/vic, TDD: failing test first):
   a. `vic hook guard` also refuses mutating git when the command's repo uses jj: command position (same `at` regex as bash-guard) `git (commit|add|stash|checkout|switch|reset|rebase|merge|restore|cherry-pick)`. Refusal text: `Refused: this repo uses jj. Use the jj equivalent (jj commit / jj new / jj squash / jj restore / jj rebase).` Read-only git (log, show, diff, status, blame, rev-parse, ls-files) passes. jj detection: walk up from stdin `.cwd` (PreToolUse JSON field) to find `.jj`; no `.jj` found ⟹ allow.
   b. `vic hook boot` = port of modules/vic/ai/vic/hooks/boot.sh (same stdout, parity) PLUS repo check on `$CLAUDE_PROJECT_DIR`: print one line `REPO LAW: <violations>; fix per /workspace LOCAL REPO LAW` when any of: no `.jj`; `vic/` missing or has no `vic/.jj`; `.beads` exists and is not a symlink to `vic/.beads`. No violation ⟹ no extra line.
   c. parity.sh keeps r1 cases green; guard corpus: every mismatch vs bash must be a new git refusal — print them, count, and show 3 samples. Add cases: git commit in jj repo refused, git commit in non-jj dir allowed, `git log` allowed, `jj commit` allowed.
3. wiring (home-manager, no activation):
   - modules/vic/ai/vic/hooks.nix: PreToolUse Bash `bash-guard.sh` ⟹ `vic hook guard`; PostToolUse Bash `cmd-ledger.sh` ⟹ `vic hook ledger`; SessionStart `boot.sh` (both entries) ⟹ `vic hook boot`. Command = store path of the package bin (`lib.getExe' pkg "vic"` + args), take the package from `out.packages.${pkgs.stdenv.hostPlatform.system}.vic-tools` (see modules/vic/rdesk.nix for `out`).
   - modules/vic/ai/statusline.nix: statusLine command ⟹ `<vic> statusline`. Keep runtimeInputs it needs on PATH? statusline calls `vic-telemetry` + `vic-pm` from PATH like bash did; keep that.
   - delete hooks/bash-guard.sh, hooks/cmd-ledger.sh, hooks/boot.sh, _scripts/statusline.sh ONLY after the eval below passes; update header comments of the edited .nix files.
   - home.packages: add vic-tools so `vic` is on PATH.

## oracle (paste outputs)
- `cargo test`, `cargo clippy --all-targets -- -D warnings`, `bash tools/vic/tests/parity.sh all` (guard may be LIMIT=5000 if full run > 5 min; say which).
- nix (APPROVED by vic: eval + build, NO activation, NO switch): `timeout 600 systemd-run --user --scope -q -p MemoryMax=12G nix build .#packages.x86_64-linux.vic-tools` then `./result/bin/vic hook guard <<< '{"tool_input":{"command":"git commit -m x"},"cwd":"/home/vic/hk/vix"}'; echo rc=$?` (expect 2).
- frodo still evaluates: `timeout 600 systemd-run --user --scope -q -p MemoryMax=12G nix eval --raw .#nixosConfigurations.frodo.config.system.build.toplevel.drvPath` prints a drvPath. Then show the generated hook commands: `... nix eval --json .#nixosConfigurations.frodo.config.home-manager.users.vic.programs.claude-code.settings.hooks.PreToolUse` contains `/bin/vic hook guard`. (Attr path may differ; find it, paste the one used.)
- negative control: break one guard refusal string, parity FAILS, revert.

## law
r1 Rust law holds (no unwrap/expect/panic/unsafe, 0 clippy, no #[allow], typed errors). Deps: no new ones. Nix: no `with`, no nested lets, keep file style.
Checkpoint each step in tools/PROGRESS.md. 3 fails same thing ⟹ stop, write blocker.
