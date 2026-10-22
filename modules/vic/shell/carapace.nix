# carapace: multi-shell completions, fish integration only.
{ ren, ... }:
{
  ren.aspects.carapace = {
    at = ren.aspects.vic-headless;
    homeManager.programs.carapace = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
