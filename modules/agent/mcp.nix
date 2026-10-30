# The MCP server as a flake app: `nix run .#yen-mcp` in the vix checkout serves the fleet in $PWD on stdio.
# A small Rust binary, `mcp/` at the top of the yen repository; its tool.nix is copied to the store. The fleet is read from the working tree,
# so answers follow edits.

{ yen, inputs, ... }:

{
  yen.aspects.mcp-app = {
    at = yen.kinds.system;
    out =
      { system, ... }:
      let
        server = system.legacyPackages.callPackage (inputs.yen + "/mcp/package.nix") { }; # the derivation the yen mcp flake builds
      in
      {
        packages.${system.name}.yen-mcp = server;
        apps.${system.name}.yen-mcp = {
          type = "app";
          program = "${server}/bin/yen-mcp";
          meta.description = "yen MCP server over the vix fleet in the working directory";
        };
      };
  };

  # vic's claude sessions ask this fleet through the same app (dogfood)
  yen.aspects.yen-mcp-claude = {
    at = yen.aspects.vic-headless;
    homeManager =
      { out, pkgs, ... }:
      let
        fleet = "/home/vic/hk/vix-yen";
      in
      {
        programs.claude-code.mcpServers.yen = {
          type = "stdio";
          command = out.apps.${pkgs.stdenv.hostPlatform.system}.yen-mcp.program;
          env = {
            YEN_FLEET = fleet;
            YEN_FLAKE = "path:${fleet}";
          };
        };
      };
  };
}
