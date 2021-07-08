{ vix-lib, ... }:
{ pkgs, ... }@args: {
  config._module.args = { vix-lib = vix-lib (args); };
  imports = [ ./pkg-overrides.nix ./pkg-sets.nix ./system-oeiuwq.nix ./user-vic.nix ];
}
