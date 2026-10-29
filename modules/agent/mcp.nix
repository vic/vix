# The MCP server as a flake app: `nix run .#yen-mcp` in the vix checkout serves the fleet in $PWD on stdio.
# The script and its tool.nix are copied to the store; the fleet is read from the working tree, so answers follow edits.
{ yen, ... }:
{
  yen.aspects.mcp-app = {
    at = yen.kinds.system;
    out =
      { system, ... }:
      let
        pkgs = system.legacyPackages;
        app = pkgs.writeShellApplication {
          name = "yen-mcp";
          runtimeInputs = [
            pkgs.jq
            pkgs.coreutils
            pkgs.git
          ]; # nix itself comes from the caller's PATH: its version, its store
          text = ''
            export Yen_FLEET="''${Yen_FLEET:-$PWD}"
            exec ${../../mcp}/yen-mcp.sh "$@"
          '';
        };
      in
      {
        apps.${system.name}.yen-mcp = {
          type = "app";
          program = "${app}/bin/yen-mcp";
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
            Yen_FLEET = fleet;
            Yen_FLAKE = "path:${fleet}";
          };
        };
      };
  };
}
