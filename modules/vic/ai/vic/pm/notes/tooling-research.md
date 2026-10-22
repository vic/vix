# Tooling research (2026-10-21)

Scope: GitHub tools for vic's AI, shell and services workflow. "nixpkgs" = `nix-search -c unstable` hit (version shown).
Excluded because vic already has them: jjui, lazyjj, jj-fzf, hunk, mergiraf, difftastic, delta, nh, nvd, nix-direnv, comma, nix-index, television, zellij, herdr, headroom, codebase-memory, omni, quipu, lightjj, gitleaks, nix-sweep.
Pick rule: CLI over daemon, low battery cost, packaged in nixpkgs.

## Claude Code: cost, sessions, hooks

| tool | repo | what it gives vic | nixpkgs | cost | verdict |
|---|---|---|---|---|---|
| ccusage | https://github.com/ccusage/ccusage | daily/session/5h-block cost per model from `~/.claude/projects` JSONL; offline. Gives a $ figure per tier to check dispatch choices | yes 20.0.17 | one-shot CLI | adopt-now |
| claude-monitor | https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor | live burn rate + "limit hit at" forecast | yes 4.0.0 | TUI, only while open | try |
| claumon | https://github.com/fabioconcina/claumon | Go single binary: forecasts, rate-limit gauges, memory browser | no | small binary | skip (ccusage covers it) |
| recall | (listed in awesome-claude-code-hooks) | full-text search + resume of Claude/Codex sessions | no | CLI | skip (omni_search covers it) |
| skillreaper | (awesome lists) | finds skills/MCPs loaded into context but never fired; quarantines them | no | one-shot | try (vic loads ~200 skills + many MCPs) |
| context-tax | (awesome lists) | measures per-turn fixed context (prompt+skills+MCP schemas) | no | one-shot, zero-dep | try |
| backpass | (awesome lists) | proposes CLAUDE.md edits from evidence in transcripts | no | one-shot | skip (overlaps omni_learn + memory) |
| claude-code-hooks-multi-agent-observability | https://github.com/disler/claude-code-hooks-multi-agent-observability | live dashboard of hook events across agents | no | bun server + web UI | skip (daemon; omni already indexes) |
| awesome-claude-code-hooks | https://github.com/ithiria894/awesome-claude-code-hooks | hook catalogue (cost-tracker, protect-tests, context-snapshot, ntfy-notify) | n/a | n/a | try (read, copy ideas only) |

## jj

| tool | repo | what it gives vic | nixpkgs | cost | verdict |
|---|---|---|---|---|---|
| jj_tui | https://github.com/faldor20/jj_tui | live graph preview while planning a rebase | no | TUI | skip (jjui + lightjj cover it) |
| oyui | (jj wiki GUI-and-TUI) | TUI merge tool + interactive diff editor for `jj split`/`jj resolve` | no | TUI | try |
| jujutsu-gi | (jj wiki GUI-and-TUI) | TUI/CLI for jj workspaces; vic runs many agent workspaces under ~/hk/workspace | no | CLI | try |

## Nix

| tool | repo | what it gives vic | nixpkgs | cost | verdict |
|---|---|---|---|---|---|
| dix | https://github.com/faukah/dix | closure diff, about 2x faster than nvd, JSON output; nh already uses it | yes 2.2.0 | one-shot | adopt-now (replace nvd in community/laptop.nix) |
| nix-output-monitor | https://github.com/maralorn/nix-output-monitor | build tree + timing; nh uses it when present | yes 2.2.0 | pipe filter | adopt-now |
| nix-tree | https://github.com/utdemir/nix-tree | interactive closure explorer: "why is X in my closure", size per dep | yes 0.8.0 | TUI, on demand | adopt-now |
| nix-fast-build | https://github.com/Mic92/nix-fast-build | nix-eval-jobs + nom, parallel eval/build of many attrs | yes 2.0.4 | heavy only while running | try (den/ren CI checks) |
| nixpkgs-review | https://github.com/Mic92/nixpkgs-review | review nixpkgs PRs locally | yes 4.0.0 | heavy builds | skip unless upstreaming |

## Rust / Lean

| tool | repo | what it gives vic | nixpkgs | cost | verdict |
|---|---|---|---|---|---|
| lean-lsp-mcp | https://github.com/oOo0oOo/lean-lsp-mcp | MCP: goal state, diagnostics, hover, loogle/leansearch, multi_attempt; agents prove against the real LSP | yes 0.31.0 | one lean server per project; local loogle optional (~2GB disk) | adopt-now (dnx Lean proofs) |
| lean4-skills | https://github.com/cameronfreer/lean4-skills | Claude skills for Lean proof work; the lean-lsp-mcp author recommends it | n/a | none | try |
| LeanExplore | https://www.leanexplore.com/docs/mcp | semantic search over Lean declarations | no | remote API | skip (lean-lsp-mcp has loogle/leansearch) |
| cargo-nextest | https://github.com/nextest-rs/nextest | parallel, process-isolated tests; clean per-test output for agents | yes 0.9.146 | build-time only | adopt-now |
| bacon | https://github.com/Canop/bacon | background check/clippy watcher; zero-warning loop | yes 3.26.0 | runs while open | try (CPU on battery) |
| cargo-mutants | https://github.com/sourcefrog/cargo-mutants | mutation testing: tests a test suite, `--in-diff` for agent PRs | yes 27.1.0 | heavy, on demand | adopt-now (oracle discipline: proves tests can fail) |
| cargo-machete | https://github.com/bnjbvr/cargo-machete | fast unused-dep finder, stable toolchain | yes 0.9.2 | one-shot | adopt-now |

## Shell / local services

| tool | repo | what it gives vic | nixpkgs | cost | verdict |
|---|---|---|---|---|---|
| atuin | https://github.com/atuinsh/atuin | SQLite shell history: cwd, exit code, duration; fish support; sync is optional | yes 18.23.0 | local only, no daemon needed | adopt-now (HM `programs.atuin`, sync off) |
| pueue | https://github.com/Nukesor/pueue | queue for long commands (builds, evals, benches) with logs; survives terminal close | yes 4.0.4 | small daemon `pueued` | try |
| watchexec | https://github.com/watchexec/watchexec | generic file-watch runner for Justfile/nix-instantiate loops | yes 2.5.1 | while running | try |
| ntfy-sh | https://github.com/binwiederhier/ntfy | push "agent done/blocked" from a Stop hook to the phone | yes 2.31.0 | CLI to ntfy.sh, or self-host | try (outward-facing, use a private topic) |

## TOP 10

1. lean-lsp-mcp: agents get the real goal state and loogle search for dnx proofs, not guesses. In nixpkgs.
2. ccusage: offline $ per session and model; puts real numbers on haiku/sonnet/opus dispatch rules.
3. cargo-mutants: mechanical check that Rust tests can fail; fits the oracle and negative-control rules.
4. atuin: searchable history with cwd and exit code; local SQLite, no sync needed.
5. dix: drop-in nvd replacement, faster, JSON output for agents; nh already uses it.
6. nix-tree: answers "why is this in my closure" without an eval script.
7. cargo-nextest: per-test isolation and clean output; less agent noise than `cargo test`.
8. nix-output-monitor: readable builds for vic; nh turns it off when stdout is not a TTY, so agents stay quiet.
9. skillreaper / context-tax: measure and cut fixed per-turn context from skills and MCP schemas.
10. cargo-machete: cheap unused-dep check before landing; stable toolchain, no build.

Sources: github.com/ccusage/ccusage, github.com/jj-vcs/jj/wiki/GUI-and-TUI, github.com/faukah/dix,
github.com/oOo0oOo/lean-lsp-mcp, leaning.in/2026/slides/dressler.pdf, tools.corrode.dev,
github.com/ithiria894/awesome-claude-code-hooks, toriihq.com Claude Code usage dashboards (2026).
Not verified: repo URLs for skillreaper, context-tax, recall, oyui, jujutsu-gi (names come from awesome lists and the jj wiki).
