# Agent tools that drive or render through a browser.
{ yen, inputs, ... }:
{
  yen.aspects.ai-browser-tools = {
    at = yen.aspects.vic-gui;
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (yen.helpers.perSystem pkgs inputs.llm-agents).packages.openspecui
          pkgs.playwright-mcp
          pkgs.mermaid-cli # diagram-mermaid-render
        ];
      };
  };
}
