{
  yen,
  inputs,
  lib,
  ...
}:
{
  yen.aspects.ai-antigravity = {
    at = yen.aspects.vic-headless;
    unfree = [
      "antigravity-cli"
      "antigravity-ide"
      "antigravity-hub"
    ];
    homeManager =
      { config, pkgs, ... }:
      let
        llm = (yen.helpers.perSystem pkgs inputs.llm-agents).packages;
        claude = config.programs.claude-code;

        # Normalize Claude Code subagent definitions for Antigravity / Gemini CLI:
        # - Strips Claude-specific keys (`model:`, `effort:`) that fail Antigravity validation
        # - Ensures `tools:` and `skills:` are valid YAML array syntax [tool1, tool2, ...]
        toAgyAgent =
          agent:
          let
            text = if lib.isDerivation agent || lib.isPath agent then builtins.readFile "${agent}" else agent;
            lines = lib.splitString "\n" text;
            filtered = builtins.filter (
              line: !lib.hasPrefix "model: " line && !lib.hasPrefix "effort: " line
            ) lines;
            fixed = map (
              line:
              if lib.hasPrefix "tools: " line && !lib.hasPrefix "tools: [" line then
                "tools: [" + (lib.removePrefix "tools: " line) + "]"
              else if lib.hasPrefix "skills: " line && !lib.hasPrefix "skills: [" line then
                "skills: [" + (lib.removePrefix "skills: " line) + "]"
              else
                line
            ) filtered;
          in
          pkgs.writeText "antigravity-agent" (lib.concatStringsSep "\n" fixed);
      in
      {
        home.packages = [
          llm.antigravity-cli
          llm.antigravity-hub
        ];

        # Antigravity IDE (nixpkgs antigravity-ide; the `antigravity` alias warns).
        programs.antigravity = {
          enable = true;
        };

        # Antigravity CLI & Gemini CLI configuration
        # Shares the identical MCP servers, skills, and context from Claude Code declarative setup
        programs.antigravity-cli = {
          enable = true;
          package = llm.antigravity-cli;

          # 1. MCP servers: automatically transformed to Antigravity schema and written to ~/.gemini/config/mcp_config.json
          # 2. Skills: symlinked to ~/.gemini/antigravity-cli/skills/
          inherit (claude) mcpServers skills;

          # 3. Instructions & context: written to ~/.gemini/GEMINI.md and ~/.gemini/AGENTS.md
          context = lib.optionalAttrs (claude.context != null) {
            GEMINI = claude.context;
            AGENTS = claude.context;
          };
        };

        # Gemini CLI compatibility & Antigravity agents/rules:
        # - ~/.gemini/skills: symlinked to ~/.gemini/antigravity-cli/skills for legacy Gemini CLI discovery
        # - ~/.gemini/settings.json: written with mcpServers for Gemini CLI
        # - ~/.gemini/antigravity-cli/agents: agent definitions discovered by agy agents
        # - ~/.gemini/agents: symlinked for legacy Gemini CLI
        # - ~/.gemini/RTK.md: required by context `@RTK.md` includes
        # - ~/.gemini/config/rules: rules from claude.rules written as global Antigravity rules
        home.file =
          let
            agyAgents = lib.mapAttrs (_name: agent: {
              source = toAgyAgent agent;
            }) claude.agents;
            agentFiles = lib.mapAttrs' (
              name: file: lib.nameValuePair ".gemini/antigravity-cli/agents/${name}.md" file
            ) agyAgents;
            ruleFiles = lib.mapAttrs' (
              name: ruleText:
              lib.nameValuePair ".gemini/config/rules/${name}.md" {
                text = ruleText;
              }
            ) (claude.rules or { });
          in
          agentFiles
          // ruleFiles
          // {
            ".gemini/skills".source =
              config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.gemini/antigravity-cli/skills";
            ".gemini/agents".source =
              config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.gemini/antigravity-cli/agents";
            ".gemini/RTK.md".source = ./vic/memory/RTK.md;
            ".gemini/settings.json".source = (pkgs.formats.json { }).generate "gemini-cli-settings.json" {
              mcpServers = config.programs.antigravity-cli.mcpServers;
            };
          };
      };
  };
}
