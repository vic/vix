# Agent tools that drive or render through a browser.
{ sven, inputs, ... }:
{
  sven.aspects.ai-browser-tools = {
    at = sven.aspects.vic-gui;
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (sven.helpers.perSystem pkgs inputs.llm-agents).packages.openspecui
          pkgs.playwright-mcp
          pkgs.mermaid-cli # diagram-mermaid-render
        ];
      };
  };
}
