{ vix-lib, nixpkgs, ... }:
{ pkgs, lib, ... }@args: {
  config._module.args = {
    vix-lib = nixpkgs.lib.extend (vix-lib args);
    inherit nixpkgs;
  };
  imports = [ ./pkg-overrides.nix ./pkg-sets.nix ./oeiuwq ./vic ];
}
