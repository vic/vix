# The Claude Code status line: `vic statusline` (Rust, packages.vic-tools).
# model+effort, ctx, 5h/7d quota, $, tokens, open PM beads, agents in flight + last subagent.
# It calls vic-telemetry + vic-pm from PATH, as the old bash script did.
{ yen, lib, ... }:
{
  yen.aspects.ai-statusline = {
    at = yen.aspects.vic-headless;
    homeManager =
      { out, pkgs, ... }:
      {
        programs.claude-code.settings.statusLine = {
          type = "command";
          command = "${lib.getExe' out.packages.${pkgs.stdenv.hostPlatform.system}.vic-tools "vic"} statusline";
          padding = 0;
        };
      };
  };
}
