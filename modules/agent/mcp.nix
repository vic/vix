# vic's claude sessions ask this fleet through the yen MCP server (dogfood): the package of the yen repository, at the locked rev.
# The skill that teaches its tools comes from the same repository (vic/ai/skills.nix).

{ yen, inputs, ... }:

{
  yen.aspects.yen-mcp-claude = {
    at = yen.aspects.vic-headless;
    homeManager =
      { pkgs, ... }:
      let
        fleet = "/home/vic/hk/vix-yen";
      in
      {
        programs.claude-code.mcpServers.yen = {
          type = "stdio";
          command = pkgs.lib.getExe (pkgs.callPackage (inputs.yen + "/mcp/package.nix") { });
          env = {
            YEN_FLEET = fleet;
            YEN_FLAKE = "path:${fleet}";
          };
        };
      };
  };
}
