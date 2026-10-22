# sini claude practices vs vic (src: ren-ports/sini-nix-config/modules/features/dev/ai)
Paths below relative to that dir. vic = /home/vic/hk/vix/modules/vic/ai.

## ADOPT
1. PreToolUse/Bash guard, exit 2 refuses · claude/claude-hooks.nix:44-48, claude/_claude/bash-guard.sh:10-34 · prose law ("never pkill -f", pgrep -f wait loops) fails when agents forget; hook is mechanical · add `bash-guard.sh` to vic/hooks/, wire in vic/hooks.nix PreToolUse matcher "Bash" (no `|| true`)
2. PreCompact hold, exit 2 on auto compaction below gate · claude/_claude/pre-compact.sh:6-40, claude-hooks.nix:58 · measured: auto boundaries were idle compaction at 22-77% ctx, costing context · add `PreCompact` hook; vic stop-gate.sh only blocks Stop
3. idleCompaction = false · claude/claude-settings.nix:36-38 · stops compaction before cache expiry · add to vic/settings.nix settings
4. permissions.ask list · claude/claude-permissions-guard.nix:9-17 (pkill, killall, git stash, deploy) · prompts even under auto mode · vic runs defaultMode=auto (vic/settings.nix) with no ask/deny; add `permissions.ask = ["Bash(pkill *)" "Bash(killall *)" "Bash(git stash *)"]`
5. permissions.deny on generated files · claude-permissions-guard.nix:21-39 · vic: deny Edit on flake.lock/generated paths in vix, ren
6. SubagentStart additionalContext brief injected into subagent · claude-hooks.nix:25, claude/_claude/subagent-brief.sh:6 · injection reaches the subagent, an instruction in the dispatch brief does not · vic only has this for cbm in mcp.nix:119; add a vic brief (report to file, scratch dir, no pkill -f, quipu mandatory)
7. SubagentStart recall measured: instruction to recall = 0 recalls in 14 dispatches, hook = mechanical · hindsight-hooks-subagent.nix:10-19 · vic's quipu-mandatory rule rides on agent text; make a SubagentStart hook run quipu_context (already seen firing as ctx text, verify it is real)
8. SessionStart matcher "compact" re-injects HANDOFF commission after compaction · claude-hooks.nix:17-20, claude-gated.nix:25-43 · SessionStart(compact) stdout is re-added verbatim · vic boot.sh runs on SessionStart; add matcher "compact" entry that cats HANDOFF.md head
9. programs.claude-code.rules (~/.claude/rules/*.md, reach subagents) · claude/claude-rules.nix:6-10 · small reason-bearing rule files paired to hook enforcement · vic puts all in skill vic + CLAUDE.md; add `rules` for nix-eval memory cap / process-safety
10. nix eval/build under MemoryMax cap enforced by hook · bash-guard.sh:16-21 · prevents OOM of host · same file as #1
11. Hook comments record measurements and dead channels (budget.sh SubagentStop "delivers NOTHING"; PreCompact stdout feeds summarizer, not agent) · claude-hooks.nix:34-36, claude-scripts.nix:21-22 · vic hooks.nix could note which channels reach the model
12. Gated hooks: only fire for configured project cwd via session-id marker · claude-gated.nix:7-23 · vic hooks fire in every project; gate pm-specific ones

## DIFFERENT
- Model: sini effortLevel xhigh, no model pin (claude-settings.nix:22); vic opus/high + CLAUDE_CODE_SUBAGENT_MODEL=sonnet (vic/settings.nix). vic claude.nix:41 sets xhigh as mkDefault, overridden.
- Agents: sini 4 gen-* roles, all model opus via @MODEL@, no effort/skills/maxTurns frontmatter, tools allowlist by name, no Edit for gate/scout (gen-agents-lib.nix:35-48); vic ~17 tiered haiku/sonnet/opus agents with model+effort+skills frontmatter (vic/agents/vic-rung.md:1-8). Vic richer.
- Agent body composed from head+shared+role+protocol parts, single-sourced (gen-agents-lib.nix:42-53); vic copies whole files, quipu tools spliced by replaceStrings (vic/agents.nix).
- Hooks: sini budget.sh gates on UserPromptSubmit/PreToolUse; vic ctx-meter.sh + stop-gate + agent-tier-gate (Agent matcher) + cmd-ledger. vic claude.nix:79-88 still wires budget.sh (sini-derived).
- Plugins: sini store-pinned marketplaces, enabledPlugins declarative (claude-base.nix:5-16, claude-settings.nix:57-66); vic no enabledPlugins.
- State: sini persistHome buckets for ~/.claude (claude-state.nix:8-30); vic n/a seen.
- LSP/MCP: both home-manager mcp; vic adds nil lspServer (claude.nix:36).

## SKIP
- gated.sh den-ag-design project gate: tied to sini's one project.
- rules-shell-zsh / bash-guard zsh lint (bash-guard.sh:22-34): vic shell is fish and agent Bash=bash.
- hindsight recall timeout 90-240s (hindsight-hooks-subagent.nix:67-77): vic uses quipu not hindsight.
- persistHome/impermanence buckets: sini-host specific.
- gen-agents head+shared composition: nice but vic agents are small (1-2K).
- codebase-memory Grep|Glob PreToolUse augmenter (codebase-memory-hooks.nix:37-50): vic already has cbm in mcp.nix.
