# vic workflow hooks, verbatim scripts in ./hooks (installed at ~/.claude/hooks):
# boot (Skill vic + HANDOFF pointer),
# cmd-ledger (every Bash cmd + full output -> ~/.cache/claude-ledger, read by
# vic-recall), stop-gate (ctx >=70% + stale HANDOFF blocks stop once),
# bash-guard (PreToolUse refusals), subagent-brief (worker contract),
# pre-compact (holds auto compaction <90%), learn-loop. omni graph refresh is a systemd user timer (tools.nix).
{
  ren,
  ...
}:
{
  ren.aspects.ai-vic-hooks = {
    at = ren.aspects.vic-headless;
    # live link into the checkout: `vic-pm learn` appends land in the repo.
    dots.".claude/skills/vic-lessons" = "claude/skills/vic-lessons";
    homeManager =
      { config, ... }:
      let
        hookOf = script: {
          type = "command";
          command = "bash \"${config.home.homeDirectory}/.claude/hooks/${script}\"";
        };
        on = scripts: [ { hooks = map hookOf scripts; } ];
        learnLoop = mode: {
          type = "command";
          command = "bash \"${config.home.homeDirectory}/.claude/hooks/learn-loop.sh\" ${mode}";
        };
      in
      {
        programs.claude-code = {
          hooksDir = ./hooks;
          rules = {
            process-safety = builtins.readFile ./rules/process-safety.md;
            nix-eval = builtins.readFile ./rules/nix-eval.md;
          };
          settings.hooks = {
            SessionStart = [
              {
                hooks = [
                  (hookOf "boot.sh")
                  (learnLoop "start")
                ];
              }
              # re-inject the HANDOFF pointer after compaction
              {
                matcher = "compact";
                hooks = [ (hookOf "boot.sh") ];
              }
            ];
            SubagentStart = on [ "subagent-brief.sh" ];
            # no `|| true` on bash-guard/pre-compact: exit 2 is the refusal
            PreCompact = on [ "pre-compact.sh" ];
            PreToolUse = [
              {
                matcher = "Bash";
                hooks = [ (hookOf "bash-guard.sh") ];
              }
              {
                matcher = "Agent";
                hooks = [ (hookOf "agent-tier-gate.sh") ];
              }
            ];
            PostToolUse = [
              {
                matcher = "Bash";
                hooks = [ (hookOf "cmd-ledger.sh") ];
              }
            ];
            Stop = [
              {
                hooks = [
                  (hookOf "stop-gate.sh")
                  (learnLoop "stop")
                ];
              }
            ];
          };
        };
      };
  };
}
