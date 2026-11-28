# AI: unfree agent CLIs and the extra agent packages on linux homes.
{ yen, ... }:
{
  yen.aspects.ai-ai = {
    at = yen.aspects.vic-headless;
    unfree = [
      "copilot-language-server"
      "claude"
      "github-copilot-cli"
    ];
  };
}
