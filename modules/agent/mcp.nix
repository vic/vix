# The MCP server as a flake app: `nix run .#sven-mcp` in the vix checkout serves the fleet in $PWD on stdio.
# The script and its tool.nix are copied to the store; the fleet is read from the working tree, so answers follow edits.
{ sven, ... }:
{
  sven.aspects.mcp-app = {
    at = sven.kinds.system;
    out =
      { system, ... }:
      let
        pkgs = system.legacyPackages;
        app = pkgs.writeShellApplication {
          name = "sven-mcp";
          runtimeInputs = [
            pkgs.jq
            pkgs.coreutils
            pkgs.git
          ]; # nix itself comes from the caller's PATH: its version, its store
          text = ''
            export SVEN_FLEET="''${SVEN_FLEET:-$PWD}"
            exec ${../../mcp}/sven-mcp.sh "$@"
          '';
        };
      in
      {
        apps.${system.name}.sven-mcp = {
          type = "app";
          program = "${app}/bin/sven-mcp";
          meta.description = "sven MCP server over the vix fleet in the working directory";
        };
      };
  };

  # vic's claude sessions ask this fleet through the same app (dogfood)
  sven.aspects.sven-mcp-claude = {
    at = sven.aspects.vic-headless;
    homeManager =
      { out, pkgs, ... }:
      let
        fleet = "/home/vic/hk/vix-sven";
      in
      {
        programs.claude-code.mcpServers.sven = {
          type = "stdio";
          command = out.apps.${pkgs.stdenv.hostPlatform.system}.sven-mcp.program;
          env = {
            SVEN_FLEET = fleet;
            SVEN_FLAKE = "path:${fleet}";
          };
        };
      };
  };
}
