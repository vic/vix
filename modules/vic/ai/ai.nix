# AI: unfree agent CLIs and the extra agent packages on linux homes.
{ yen, ... }:
{
  yen.aspects.ai-ai = {
    at = yen.aspects.vic-headless;
    unfree = yen.helpers.allowUnfree [
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
        ];
      };
  };
}
