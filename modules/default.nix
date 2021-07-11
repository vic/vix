{ vix-lib, nixpkgs, ... }:
{ pkgs, ... }@args: {
  config._module.args = {
    vix-lib = vix-lib (args);
    inherit nixpkgs;
  };
  imports =
    [ ./pkg-overrides.nix ./pkg-sets.nix ./system-oeiuwq.nix ./user-vic.nix ];
}
