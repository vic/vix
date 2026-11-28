# Claude Code: declarative settings.json using Yen's built-in `reduce.layers` (zero custom reducer!).
{
  yen,
  reduce,
  inputs,
  lib,
  ...
}:
{
  yen.kinds.user.sinks.claude = {
    reduce = reduce.layers;
    into.homeManager =
      { claude, ... }:
      {
        programs.claude-code.settings = claude;
      };
  };

  yen.aspects.ai-claude = {
    at = yen.aspects.vic-headless;
    git-ignores = [ ".claude" ];
    claude =
      { claude-allow, ... }:
      {
        rank = 0;
        set = {
          theme = "auto";
          verbose = true;
          effortLevel = "xhigh";
          remoteControlAtStartup = false;
          includeCoAuthoredBy = false;
          gitAttribution = false;
          attribution = {
            commit = "";
            pr = "";
          };
          autoMemoryDirectory = "~/.claude/memory";
          teammateMode = "in-process";
          permissions.allow = claude-allow;

          env = {
            CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
            ENABLE_TOOL_SEARCH = "auto:5";
            DISABLE_AUTO_COMPACT = "1";
          };
        };
      };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.nodejs_22
          pkgs.jq
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          pkgs.socat
          pkgs.bubblewrap
        ];

        programs.claude-code = {
          enable = true;
          package = (yen.helpers.perSystem pkgs inputs.llm-agents).packages.claude-code;
          enableMcpIntegration = true;

          lspServers.nix = {
            command = lib.getExe pkgs.nil;
            extensionToLanguage.".nix" = "nix";
          };
        };
      };
  };
}
