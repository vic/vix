{ vic, den, ... }:
{
  vic.everywhere.includes = [ vic.ai ];

  vic.ai.includes = [
    (den.provides.unfree [
      "copilot-language-server"
      "claude"
      "github-copilot-cli"
    ])
  ];

  vic.ai.hmLinux =
    { pkgs, ... }:
    {
      # `claude` comes from programs.claude-code.package (llm-agents, claude.nix).
      home.packages = [
        pkgs.github-copilot-cli
        pkgs.copilot-language-server
        pkgs.aider-chat
        pkgs.gemini-cli-bin
      ];
    };
}
