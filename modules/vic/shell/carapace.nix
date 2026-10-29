# carapace: multi-shell completions, fish integration only.
{ yen, ... }:
{
  yen.aspects.carapace = {
    at = yen.aspects.vic-headless;
    homeManager.programs.carapace = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
