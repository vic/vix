# tools/vic rung 3: `vic recall build` + `vic hook recall` + `vic hook mark`

Workspace: /run/user/1000/jj-ws/vix/r3 (jj workspace of ~/hk/vix). Work ONLY there. NEVER run jj or git. Never write ~/.local/share/quipu (read the live db only via `quipu read`; tests use a copy).

## P
Agents forget quipu as context grows. The harness pushes the 3 most relevant recorded lessons into every prompt and every subagent start, so no agent has to remember. Transcript changes get queued for the learner (vic-shadow, r5).

## I
1. `vic recall build [--db PATH]` (default db ~/.local/share/quipu/quipu.db):
   - runs `quipu read '<SPARQL>' --db PATH` (subprocess, the same quipu binary the MCP servers use; never link quipu). SPARQL: label + comment of every entity whose label starts with `ledger:` (see modules/vic/ai/vic/skills/vic-stack/SKILL.md QUIPU recipe; drop LIMIT).
   - parses its output (TSV: header `l\tc`, a dashes line, then rows of two double-quoted strings; then a blank + `N results` trailer). Measure the exact escaping on a db COPY first (`cp ~/.local/share/quipu/quipu.db* $TMP/`): quotes, tabs, newlines inside values. Parse into typed rows: `Lesson { project: Project, kind: Kind, slug, text }` from label `ledger:<project>/<kind>/<slug>`. Kind = closed enum: Mistake, Evidence, Ruling, Decision, Landed, Bead, Handoff, State, Other(String) — a label that does not parse is skipped and counted.
   - writes cache `~/.cache/vic/recall.json` atomically (tmp + rename). Prints `recall: N lessons, M skipped`.
   - measured today: 95 ledger rows, `quipu read` ~1.4 s. That is why the hook reads the cache, never quipu.
2. `vic hook recall` (UserPromptSubmit and SubagentStart):
   - stdin JSON: `hook_event_name`, `cwd`, and `prompt` (UserPromptSubmit) or `agent_type` (SubagentStart; also use any prompt/description field present — log the real SubagentStart payload once from a fixture you capture by reading Claude Code docs or an existing transcript; if unknown, use `agent_type` only).
   - project = name of the dir that holds the nearest `.jj` walking up from cwd (fallback: basename of cwd).
   - score each cached lesson: +3 project match, + 1 per shared token (lowercase, [a-z0-9_-]{4,}, minus a small stopword list), kind weight Mistake/Ruling ×2, Evidence/Decision ×1, others ×0.5. Keep score > project-only (at least 1 shared token).
   - stdout: `{"hookSpecificOutput":{"hookEventName":<same event>,"additionalContext":"QUIPU RECALL (verify before use): ..."}}` with the top 3, each `[<kind> <label>] <text truncated to 160 chars>`, total additionalContext ≤ 600 bytes. No match / no cache / bad input ⟹ no stdout, exit 0 (fail-open).
   - budget: < 5 ms avg over 50 runs with the real cache (measure with `hyperfine -N` if available via nix-shell -p hyperfine, else date loop).
3. `vic hook mark` (Stop, SubagentStop, PreCompact):
   - append one JSON line `{"ts","event","session_id","transcript_path","bytes"}` (bytes = transcript file size now) to `~/.cache/vic/learn-queue.jsonl`. No stdout, exit 0 always. Never block.
4. Nix wiring (modules/vic/ai/vic/hooks.nix, same `out.packages...vic-tools` pattern r2 used):
   - UserPromptSubmit += `vic hook recall`; SubagentStart += `vic hook recall` (keep subagent-brief.sh).
   - Stop, SubagentStop += `vic hook mark`. PreCompact: keep pre-compact.sh FIRST (its exit 2 holds compaction), add `vic hook mark` after it.
   - systemd user service + timer `vic-recall-build` (homeLinux): every 15 min + OnBootSec 2min, Nice 19, MemoryMax 512M, ExecStart `vic recall build`, PATH must contain quipu (use the same quipu package mcp.nix uses: modules/vic/ai/_pkgs/quipu.nix; find how mcp.nix gets it).

## oracle (paste outputs)
- TDD: failing tests first. Unit tests: label parse (good, bad, Other kind), TSV parse incl. the escapes you measured, scoring order (mistake beats evidence at equal tokens; project bonus), 600-byte cap, fail-open on garbage stdin. Each < 1 s.
- `cargo test`, `cargo clippy --all-targets -- -D warnings`, `cargo fmt --check` green (toolchain `timeout 600 systemd-run --user --scope -q -p MemoryMax=8G nix-shell -p cargo rustc clippy rustfmt --run '...'`), then `rm -rf tools/target` before nix eval.
- e2e on a db COPY: `vic recall build --db $COPY` prints counts (N = row count of the same SPARQL); then `echo '{"hook_event_name":"UserPromptSubmit","cwd":"/home/vic/hk/vix","prompt":"<words from one real mistake label>"}' | vic hook recall` shows that mistake first. Negative: a prompt with no shared tokens ⟹ empty stdout.
- latency number for `vic hook recall` (avg ms, 50 runs).
- Vic approved capped eval/build, NO activation: `nix build "path:$PWD#packages.x86_64-linux.vic-tools"`; eval `...home-manager.users.vic.programs.claude-code.settings.hooks.UserPromptSubmit` contains `vic hook recall`; `...hooks.PreCompact` lists pre-compact.sh before `vic hook mark`; `...systemd.user.timers` has `vic-recall-build`; frodo toplevel drvPath evaluates. (Use `path:$PWD#nixosConfigurations.frodo.config...`.)
## law
Rust law from r1/r2 (no unwrap/expect/panic/unsafe, typed errors, newtypes Project/Kind, 0 clippy, no #[allow], no new deps). Checkpoint tools/PROGRESS.md each step. 3 fails ⟹ stop + report.
