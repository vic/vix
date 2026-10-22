# The Claude Code status line: one line from _scripts/statusline.sh.
# model+effort, ctx, 5h/7d quota, $, tokens, open PM beads, agents in flight + last subagent.
{
  ren,
  ...
}:
{
  ren.aspects.ai-statusline = {
    at = ren.aspects.vic-headless;
    homeManager =
      {
        lib,
        pkgs,
        ...
      }:
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
