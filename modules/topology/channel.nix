# Package channels: which nixpkgs, home-manager and nix-darwin a machine builds with.
{
  ren,
  lib,
  inputs,
  ...
}:
let
  t = lib.types;
in
{
  _module.args.pkgsOf = m: m.channel.nixpkgs.legacyPackages.${m.system.name}; # m: anything with channel + system

  ren.kinds.channel = {
    nixpkgs = t.raw;
    home-manager = t.raw;
    darwin = t.raw;
  };
  ren.channel.unstable = { inherit (inputs) nixpkgs home-manager darwin; };
}
