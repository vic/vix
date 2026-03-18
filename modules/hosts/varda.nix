{ vix, ... }:
{
  den.aspects.varda = {
    includes = [
      vix.nix-settings
      vix.darwin-base
    ];
  };
}
