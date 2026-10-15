# vic workflow hooks, verbatim scripts in ./hooks (installed at ~/.claude/hooks):
# boot (Skill vic + HANDOFF pointer), ctx-meter (rule pulse >=60%),
# cmd-ledger (every Bash cmd + full output -> ~/.cache/claude-ledger, read by
# vic-recall), stop-gate (ctx >=70% + stale HANDOFF blocks stop once),
# omni-ingest (detached, flock-guarded omni graph refresh).
{ vic, ... }:
{
  vic.ai.includes = [ vic.ai.vic-hooks ];
  vic.ai.vic-hooks.homeManager =
    { config, ... }:
    let
      hookOf = script: {
        type = "command";
        command = "bash \"${config.home.homeDirectory}/.claude/hooks/${script}\"";
      };
      on = scripts: [ { hooks = map hookOf scripts; } ];
    in
    {
      programs.claude-code = {
        hooksDir = ./hooks;
        settings.hooks = {
          SessionStart = on [ "boot.sh" ];
          UserPromptSubmit = on [ "ctx-meter.sh" ];
          PostToolUse = [
            {
              matcher = "Bash";
              hooks = [ (hookOf "cmd-ledger.sh") ];
            }
          ];
          Stop = on [
            "stop-gate.sh"
            "omni-ingest.sh"
          ];
        };
      };
    };
}
