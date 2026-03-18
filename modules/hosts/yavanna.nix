{ vix, ... }:
{
  den.aspects.yavanna = {
    includes = [
      vix.nix-settings
      vix.darwin-base
    ];
  };
}
