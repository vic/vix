# carapace: multi-shell completions, fish integration only.
{ sven, ... }:
{
  sven.aspects.carapace = {
    at = sven.aspects.vic-headless;
    homeManager.programs.carapace = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
