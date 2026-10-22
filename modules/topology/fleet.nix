# Root of the scope tree, and the systems machines are built for.
{
  ren,
  inputs,
  lib,
  ...
}:
let
  vix = ren.helpers;
  pkgs = inputs.nixpkgs.legacyPackages;
in
{
  ren.kinds.fleet.below = [
    ren.kinds.system
    ren.kinds.host
    ren.kinds.mac
    ren.kinds.home
  ];
  ren.kinds.system.darwin = vix.opt lib.types.bool false;
  # nixpkgs for flake outputs at a system (machines build with their channel); `pkgs` is a Ren-reserved field
  ren.kinds.system.legacyPackages = lib.types.raw;

  ren.fleet.vix = { };
  ren.system.x86_64-linux.legacyPackages = pkgs.x86_64-linux;
  ren.system.aarch64-linux.legacyPackages = pkgs.aarch64-linux;
  ren.system.aarch64-darwin = {
    darwin = true;
    legacyPackages = pkgs.aarch64-darwin;
  };
}
