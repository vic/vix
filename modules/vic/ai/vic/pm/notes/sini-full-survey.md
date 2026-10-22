# sini full config survey vs vic (2026-10-21)
sini = /home/vic/hk/ren-ports/sini-nix-config/modules/features. vic = /home/vic/hk/vix/modules.
Already-ported items (sini-claude-practices.md) are excluded. Note: most of sini dev/ai is ALREADY in vic
(CLAUDE_ENV_FILE + load-direnv on SessionStart/CwdChanged, ENABLE_TOOL_SEARCH, attribution off,
agent teams, rtk hook, known_marketplaces autoUpdate=false, nil lspServer, subagent-stop.sh): see
vic/ai/claude.nix:41-100, vic/ai/tools.nix:93-101, vic/ai/plugins.nix:62-64. Remaining gaps are small.

## ADOPT-AI
1. Ignore `.codegraph` index dirs globally + allow `Bash(codegraph *)` · dev/ai/codegraph.nix:23-24 ·
   vic uses codegraph per project (CLAUDE.md); an un-ignored `.codegraph/` shows as dirty/untracked in jj
   and can get snapshotted into commits · vic/vcs/git.nix git-ignores list: add ".codegraph";
   vic/ai/vic/settings.nix claude-allow: add "Bash(codegraph *)".
2. Ignore agent output dirs globally · dev/ai/llm-agents.nix:15-18 ("/AGENTS.md", "/graphify-out/") ·
   stops tool droppings getting into jj snapshots · vic/vcs/git.nix git-ignores: add whichever of these
   vic's tools produce (graphify not installed in vic -> only add if used).
3. Hook comments that record dead channels/measurements · dev/ai/claude/claude-hooks.nix:32-36,54 ·
   vic/ai/claude.nix:99 still wires SubagentStop subagent-stop.sh, whose stdout reaches no one
   (vic README.md:111 says so) · keep it for its log, but add sini's one-line "dead channel, log only"
   comment at vic/ai/claude.nix:99 so no one relies on its message.
4. Retire duplicate budget.sh PreToolUse/Agent gate if ctx-meter/agent-tier-gate cover it ·
   sini moved budget gate to every tool (claude-hooks.nix:42-43) and retired SubagentStop budget ·
   vic runs both vic/ai/claude.nix:90-98 (budget.sh) and vic/ai/vic/hooks.nix (ctx-meter, agent-tier-gate)
   = two context gates on the same event · pick one; drop the budget.sh SessionStart + PreToolUse
   entries in vic/ai/claude.nix if ctx-meter.sh owns the gate. Needs vic call.

## ADOPT-WORKFLOW
1. earlyoom swap arm defused by zram · perf/zram-swap.nix:15-23 · vic community/laptop.nix:21-24 sets
   freeSwapThreshold=10: earlyoom kills only when BOTH mem<10% AND swap<10%. frodo has zram(50%) + a disk
   swap partition (hosts/frodo/_nixos/disko.nix:21-24), so earlyoom waits until disk swap is ~full =
   minutes of thrash on a low-power laptop · community/laptop.nix: freeMemThreshold=5,
   freeMemKillThreshold=2 (perf/zram-swap.nix:29-30). Swap arm: sini says hosts with real disk swap
   should keep it discriminating (zram-swap.nix:20-21), so either keep 10 or set 100 if vic prefers
   memory-only kills. Recommend 100 on frodo: hibernate swap is not meant as working swap.
2. zram 25% not 50% · perf/zram-swap.nix:5-9 · zram pages sit in the same RAM; 50% under pressure swaps
   into its own headroom · community/laptop.nix:20: zramSwap.memoryPercent = 25.
3. systemd-oomd pressure kill on nix-daemon slice · nix/nix-nixos.nix:31-33 · MemoryHigh/Max are static;
   ManagedOOMMemoryPressure kills a build on sustained PSI before the desktop freezes · community/
   nix-daemon.nix:7-10: add ManagedOOMMemoryPressure = "kill"; ManagedOOMMemoryPressureLimit = "50%"
   (needs systemd.oomd.enable, NixOS default true; verify on frodo).
4. Lowest IO priority for daemon + gc · nix/nix-nixos.nix:24-26,48-51 · vic sets class idle but no
   priority; idle class already ignores priority mostly, so tiny win · community/laptop.nix:31-32 add
   nix.daemonIOSchedPriority = 7; nix-daemon.nix:15-18 add IOSchedulingPriority = 7. Low value.
5. mergiraf syntax-aware merges for git AND jj · dev/git/mergiraf.nix:3-7 · vic + agents rebase many
   jj workspaces onto main; mergiraf auto-resolves structural conflicts (Nix, Rust supported) so fewer
   conflicted landings · vic/vcs/git.nix (or vcs/jujutsu): programs.mergiraf = { enable = true;
   enableGitIntegration = true; enableJujutsuIntegration = true; }.
6. nix-your-shell (fish stays fish inside `nix shell`/`nix develop`) · dev/lang/nix.nix:16 · vic shell is
   fish; without it `nix develop` drops to bash · vic/shell/fish.nix: programs.nix-your-shell.enable = true.
7. Nix review tools · dev/lang/nix.nix:7-14 (nixpkgs-review, nix-eval-jobs) · nix-eval-jobs evaluates
   many attrs with per-worker memory cap (fits nix-eval rule) · vic/dev/nix.nix home.packages add
   nix-eval-jobs (+ nixpkgs-review only if vic does nixpkgs PRs).
8. Disable docs build · perf/disable-docs.nix:5-11 · skips man-cache/nixos-manual rebuild on every
   switch, real time on a weak laptop · community/laptop.nix: documentation.{nixos,info,doc}.enable =
   false. Keep man.enable (agents and vic read man pages).
9. Faster substitution · nix/nix.nix:19-21 (http-connections=128, max-substitution-jobs=128,
   log-lines=25) · faster cache pulls; log-lines=25 gives agents more build error context per failure ·
   community/nix-settings.nix:48-53 nix-tuning block: add log-lines = 25 (others optional on wifi).

## DIFFERENT (neutral)
- Permissions: sini explicit allow list incl. git push origin main (claude-permissions.nix:8-74);
  vic defaultMode=auto + small ask/deny (vic/ai/vic/settings.nix:37-49). vic never pushes; keep.
- MCP remote servers: sini headersHelper reads bearer file at connect (claude-extensions.nix:45-49);
  vic mcp.nix has no remote bearer MCPs seen. Pattern worth reusing only if one appears.
- Effort: sini xhigh (claude-settings.nix:22); vic opus/high + sonnet subagents (settings.nix:25-27).
- GC: sini --delete-older-than 8d, auto-optimise-store (nix.nix:24,50-53); vic weekly gc +
  optimise.automatic (community/nix-settings.nix:21,36-37) + nix-sweep. Equivalent.
- Activation diff: vic nvd on every switch (laptop.nix:35-42); sini none seen. vic ahead.
- direnv: both nix-direnv + keep-outputs (sini dev/shell/direnv.nix:5-8; vic vic/shell/direnv.nix:30).
  sini also sets warn_timeout = 0 (direnv.nix:18): hides "taking a while" spam in agent Bash output.
  Optional one-liner in vic/shell/direnv.nix.
- Mux: sini sesh/zellij/tmux/herdr (dev/mux/*); vic herdr (vic/ai/herdr.nix). Taste.
- Git: sini pull.rebase, diff3, pushInsteadOf (git.nix:78-88); vic is jj-first. Taste.

## SKIP
- hindsight*, _hindsight-mcp: vic dropped hindsight.
- xmsg*, hermes, pi*, antigravity, opencode*, hyperqwen, ninfer, searxng: sini-specific infra/agents.
- beads*: vic tracker is GH issues (memory vix-gh-issues-not-beads).
- claude-state persist buckets, gated.sh: sini impermanence / one-project gate.
- codebase-memory Grep|Glob augmenter (codebase-memory-hooks.nix:37-50): skipped in earlier note;
  vic already gets the SubagentStart cbm reminder.
- brag/hyperframes/gstack/ui-ux skills: vic already has the skills it wants listed; no workflow gain.
- fstrim (perf/ssd.nix:4-7): NixOS enables services.fstrim by default.
- attic CI cache / remote builders (nix.nix:34, nix/remote-build-*): private infra, not vic's.
- lix (nix/lix.nix): not read; implementation swap, out of scope.
