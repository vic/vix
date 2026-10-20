# Agent tools that drive or render through a browser.
{
  inputs,
  lib,
  ren,
  ...
}:
let
  vix = import ../../_lib.nix { inherit lib; };
in
{
  ren.aspects.ai-browser-tools = {
    at = ren.aspects.vic-gui;
    homeManager = vix.mod (
      {
        lib,
        pkgs,
        ...
      }:
      let
        notebooklm-mcp = pkgs.writeShellApplication {
          name = "notebooklm-mcp";
          runtimeInputs = [ pkgs.nodejs_24 ];
          text = ''exec npx --yes -p notebooklm-mcp@2.0.0 notebooklm-mcp "$@"'';
        };
      in
      {
        home.packages = [
          notebooklm-mcp
          (vix.perSystem pkgs inputs.llm-agents).packages.openspecui
          pkgs.playwright-mcp
          pkgs.mermaid-cli # diagram-mermaid-render
        ];

        # notebooklm-mcp logs in through a browser window.
        programs.claude-code.mcpServers.notebooklm = {
          type = "stdio";
          command = lib.getExe' pkgs.nodejs_24 "npx";
          args = [ "notebooklm-mcp@latest" ];
        };
      }
    );
  };
}
