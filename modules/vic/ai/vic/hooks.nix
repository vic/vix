# vic workflow hooks. boot, bash-guard (PreToolUse refusals + jj law) and
# cmd-ledger (every Bash cmd + full output -> ~/.cache/claude-ledger, read by
# vic-recall) are the Rust `vic hook boot|guard|ledger` (packages.vic-tools).
# The rest are verbatim scripts in ./hooks (installed at ~/.claude/hooks):
# stop-gate (ctx >=70% + stale HANDOFF blocks stop once),
# subagent-brief (worker contract), pre-compact (holds auto compaction <90%),
# learn-loop.
{
  yen,
  inputs,
  lib,
  ...
}:
{
  yen.aspects.ai-vic-hooks = {
    at = yen.aspects.vic-headless;
    # live link into the checkout: `vic-pm learn` appends land in the repo.
    dots.".claude/skills/vic-lessons" = "claude/skills/vic-lessons";
    homeManager =
      {
        config,
        out,
        pkgs,
        ...
      }:
      let
        hookOf = script: {
          type = "command";
          command = "bash \"${config.home.homeDirectory}/.claude/hooks/${script}\"";
        };
        vicTools = out.packages.${pkgs.stdenv.hostPlatform.system}.vic-tools;
        vic = lib.getExe' vicTools "vic";
        vicHook = args: {
          type = "command";
          command = "${vic} ${args}";
        };
        on = scripts: [ { hooks = map hookOf scripts; } ];
        learnLoop = mode: {
          type = "command";
          command = "bash \"${config.home.homeDirectory}/.claude/hooks/learn-loop.sh\" ${mode}";
        };
      in
      {
        home.packages = [ vicTools ];
        # shortcut: sessions started before the Rust port still call these paths; drop once none run.
        home.file = lib.mapAttrs' (
          script: sub:
          lib.nameValuePair ".claude/hooks/${script}" {
            executable = true;
            text = "#!/bin/sh\nexec ${vic} hook ${sub}\n";
          }
        ) {
          "bash-guard.sh" = "guard";
          "cmd-ledger.sh" = "ledger";
          "boot.sh" = "boot";
        };
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
                  (vicHook "hook boot")
                  (learnLoop "start")
                ];
              }
              # re-inject the HANDOFF pointer after compaction
              {
                matcher = "compact";
                hooks = [ (vicHook "hook boot") ];
              }
            ];
            SubagentStart = [
              {
                hooks = [
                  (hookOf "subagent-brief.sh")
                  (vicHook "hook recall")
                ];
              }
            ];
            UserPromptSubmit = [ { hooks = [ (vicHook "hook recall") ]; } ];
            SubagentStop = [ { hooks = [ (vicHook "hook mark") ]; } ];
            # no `|| true` on bash-guard/pre-compact: exit 2 is the refusal, so it stays first
            PreCompact = [
              {
                hooks = [
                  (hookOf "pre-compact.sh")
                  (vicHook "hook mark")
                ];
              }
            ];
            PreToolUse = [
              {
                matcher = "Bash";
                hooks = [ (vicHook "hook guard") ];
              }
              {
                matcher = "Agent";
                hooks = [ (hookOf "agent-tier-gate.sh") ];
              }
            ];
            PostToolUse = [
              {
                matcher = "Bash";
                hooks = [ (vicHook "hook ledger") ];
              }
            ];
            Stop = [
              {
                hooks = [
                  (hookOf "stop-gate.sh")
                  (learnLoop "stop")
                  (vicHook "hook mark")
                ];
              }
            ];
          };
        };
      };

    # quipu read is ~1.4 s, so the recall hook reads this cache instead.
    homeLinux =
      { pkgs, out, ... }:
      let
        vicTools = out.packages.${pkgs.stdenv.hostPlatform.system}.vic-tools;
        quipu = pkgs.callPackage ../_pkgs/quipu.nix { src = inputs.quipu; };
      in
      {
        systemd.user.services.vic-recall-build = {
          Unit.Description = "Rebuild the vic recall cache from the quipu ledger";
          Service = {
            Type = "oneshot";
            Environment = [ "PATH=${quipu}/bin" ];
            ExecStart = "${lib.getExe' vicTools "vic"} recall build";
            Nice = 19;
            MemoryMax = "512M";
          };
        };
        systemd.user.timers.vic-recall-build = {
          Unit.Description = "Refresh the vic recall cache";
          Timer = {
            OnBootSec = "2min";
            OnUnitActiveSec = "15min";
          };
          Install.WantedBy = [ "timers.target" ];
        };
      };
  };
}
