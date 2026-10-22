# Agent tools that drive or render through a browser.
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{
  ren.aspects.ai-browser-tools = {
    at = ren.aspects.vic-gui;
    homeManager =
      {
        pkgs,
        ...
      }:
      {
        home.packages = [
          (vix.perSystem pkgs inputs.llm-agents).packages.openspecui
          pkgs.playwright-mcp
          pkgs.mermaid-cli # diagram-mermaid-render
        ];
      };
  };
}
