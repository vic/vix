# AI: unfree agent CLIs and the extra agent packages on linux homes.
{
  ren,
  vicAt,
  mod,
  allowUnfree,
  ...
}:
{
  ren.aspects.ai-ai = {
    at = vicAt.core;
    unfree = allowUnfree [
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
