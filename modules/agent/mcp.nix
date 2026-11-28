# Yen MCP server wiring (enabled automatically when `inputs.yen` ships `/mcp/package.nix`).
{
  yen,
  inputs,
  ...
}:
{
  yen.aspects.yen-mcp-claude = {
    at = yen.aspects.vic-headless;
    homeManager =
      { pkgs, lib, ... }:
      lib.optionalAttrs (builtins.pathExists (inputs.yen + "/mcp/package.nix")) {
        programs.claude-code.mcpServers.yen = {
          type = "stdio";
          command = lib.getExe (pkgs.callPackage (inputs.yen + "/mcp/package.nix") { });
          env = {
            YEN_FLEET = "/home/vic/hk/vix-clean";
            YEN_FLAKE = "path:/home/vic/hk/vix-clean";
          };
        };
      };
  };
}
