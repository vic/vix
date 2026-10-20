# AI: unfree agent CLIs and the extra agent packages on linux homes.
{
  lib,
  ren,
  ...
}:
let
  vix = import ../../_lib.nix { inherit lib; };
in
{
  ren.aspects.ai-ai = {
    at = ren.aspects.vic-headless;
    unfree = vix.allowUnfree [
      "copilot-language-server"
      "claude"
      "github-copilot-cli"
    ];
    # `claude` comes from programs.claude-code.package (llm-agents, claude.nix).
    homeLinux =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.github-copilot-cli
          pkgs.copilot-language-server
          pkgs.aider-chat
          pkgs.gemini-cli-bin
        ];
      };
  };
}
