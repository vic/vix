# The Claude Code status line: one line from _scripts/statusline.sh.
# model+effort, ctx, 5h/7d quota, $, tokens, open PM beads, agents in flight + last subagent.
{ sven, lib, ... }:
{
  sven.aspects.ai-statusline = {
    at = sven.aspects.vic-headless;
    homeManager =
      { pkgs, ... }:
      {
        programs.claude-code.settings.statusLine = {
          type = "command";
          command = lib.getExe (
            pkgs.writeShellApplication {
              name = "statusline";
              runtimeInputs = [
                pkgs.jq
                pkgs.gawk
                pkgs.coreutils
                pkgs.gnugrep
              ];
              text = builtins.readFile ./_scripts/statusline.sh;
            }
          );
          padding = 0;
        };
      };
  };
}
