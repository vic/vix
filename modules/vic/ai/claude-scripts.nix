# Claude Code hooks (direnv snapshot, budget gate, subagent-stop) and the scripts they run, under ~/.claude.
{ yen, ... }:
{
  yen.aspects.ai-claude-scripts = {
    at = yen.aspects.vic-headless;
    homeManager =
      { config, ... }:
      let
        hook = script: {
          type = "command";
          command = "bash ${config.home.homeDirectory}/.claude/${script} || true";
        };
        on = script: [ { hooks = [ (hook script) ]; } ];
      in
      {
        programs.claude-code.settings = {
          # CC prepends this file to every Bash tool shell; the hooks keep it a
          # snapshot of the cwd's direnv, so agents see the devshell.
          env.CLAUDE_ENV_FILE = "${config.home.homeDirectory}/.claude/direnv-snapshot.sh";

          # Session start and cwd change only, never per tool call: evaluating
          # direnv on every shell fork-bombs the host.
          hooks = {
            SessionStart = on "load-direnv.sh" ++ on "budget.sh SessionStart";
            CwdChanged = on "load-direnv.sh";
            # Before a dispatch, where a "no new dispatch" gate can still bite.
            PreToolUse = [
              {
                matcher = "Agent";
                hooks = [ (hook "budget.sh PreToolUse") ];
              }
            ];
            SubagentStop = on "subagent-stop.sh";
          };
        };

        # A silent idle is the failure this names: agents stop without delivering, and
        # the reflex (re-dispatch) duplicates finished work.
        home.file.".claude/subagent-stop.sh" = {
          executable = true;
          text = builtins.readFile ./_scripts/subagent-stop.sh;
        };

        # One budget line per firing: context %, 5h/7d quota (from headroom's poller),
        # and the gate tripped. Start new work up to 75% ctx, close out from 90%; a 7d
        # quota >= 95% means finish in-flight and dispatch nothing new.
        # Run on demand:  printf '{"transcript_path":"<session>.jsonl"}' | ~/.claude/budget.sh manual
        home.file.".claude/budget.sh" = {
          executable = true;
          text = builtins.readFile ./_scripts/budget.sh;
        };

        home.file.".claude/load-direnv.sh" = {
          executable = true;
          text = builtins.readFile ./_scripts/load-direnv.sh;
        };
      };
  };
}
