# Root of the scope tree, and the systems machines are built for.
{
  ren,
  inputs,
  lib,
  ...
}:
let
  vix = import ../_lib.nix { inherit lib; };
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
  ren.kinds.system.pkgs = lib.types.raw;

  ren.fleet.vix = { };
  ren.system.x86_64-linux.pkgs = pkgs.x86_64-linux;
  ren.system.aarch64-linux.pkgs = pkgs.aarch64-linux;
  ren.system.aarch64-darwin = {
    darwin = true;
    pkgs = pkgs.aarch64-darwin;
  };
}
