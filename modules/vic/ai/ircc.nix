# ircc: local IRC-like chat between Claude Code sessions; package + ircc MCP server for every Claude Code session.
{ yen, inputs, lib, ... }:
{
  yen.aspects.ai-ircc = {
    at = yen.aspects.vic-headless;
    flake-file.inputs.ircc = {
      url = "github:vic/ircc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homeManager =
      { pkgs, ... }:
      let
        ircc = (yen.helpers.perSystem pkgs inputs.ircc).packages.default;
      in
      {
        home.packages = [ ircc ];
        programs.claude-code.mcpServers.ircc = {
          type = "stdio";
          command = lib.getExe' ircc "ircc";
          args = [ "mcp" ];
        };
      };
  };
}
