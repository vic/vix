# Agent CLIs from numtide/llm-agents.nix, with their Claude Code wiring.
{
  yen,
  inputs,
  lib,
  ...
}:
{
  yen.aspects.ai-tools = {
    at = yen.aspects.vic-headless;
    claude-allow = [
      "Bash(br *)"
      "Bash(codegraph *)"
    ];
    git-ignores = [
      ".codegraph"
      "/AGENTS.md"
    ];
    homeManager =
      { pkgs, ... }:
      let
        llm = (yen.helpers.perSystem pkgs inputs.llm-agents).packages;

        calldiff = pkgs.writeShellApplication {
          name = "calldiff";
          runtimeInputs = [ pkgs.nodejs ];
          text = ''exec npx --yes calldiff "$@"'';
        };

      in
      {
        home.packages = [
          llm.rtk
          # llm.hunk
          llm.beads-rust
          llm.codegraph
          #calldiff
        ];

        programs.claude-code = {
          mcpServers.codegraph = {
            type = "stdio";
            command = lib.getExe' llm.codegraph "codegraph";
            args = [
              "serve"
              "--mcp"
            ];
          };

          # br resolves its workspace from cwd unless pinned; point this at your tracker:
          # settings.env.BEADS_DIR = "/path/to/tracker-repo/.beads";

          # Rewrites eligible Bash commands to `rtk <cmd>`, compressing their
          # output before it reaches the model (what `rtk init -g --hook-only` installs).
          settings.hooks.PreToolUse = [
            {
              matcher = "Bash";
              hooks = [
                {
                  type = "command";
                  command = "rtk hook claude";
                }
              ];
            }
          ];
        };
      };
  };
}
