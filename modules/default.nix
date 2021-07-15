{ vix-lib, nixpkgs, home-manager, ... }@inputs:
{ pkgs, lib, ... }@args: {
  config._module.args = inputs // { vix-lib = vix-lib args; };
  imports = [ ./pkg-overrides.nix ./pkg-sets.nix ./oeiuwq ./vic ];
}
