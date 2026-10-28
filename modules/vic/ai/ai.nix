# AI: unfree agent CLIs and the extra agent packages on linux homes.
{ sven, ... }:
{
  sven.aspects.ai-ai = {
    at = sven.aspects.vic-headless;
    unfree = sven.helpers.allowUnfree [
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
