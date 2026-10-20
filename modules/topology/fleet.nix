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
  # nixpkgs for flake outputs at a system (machines build with their channel). Ren forces instance
  # fields (to spot instance refs), and nixpkgs throws on x86_64-darwin: null there, no packages.
  ren.kinds.system.pkgs = vix.maybe lib.types.raw;

  ren.fleet.vix = { };
  ren.system.x86_64-linux.pkgs = pkgs.x86_64-linux;
  ren.system.aarch64-linux.pkgs = pkgs.aarch64-linux;
  ren.system.x86_64-darwin.darwin = true; # dropped by nixpkgs 26.11
  ren.system.aarch64-darwin = {
    darwin = true;
    pkgs = pkgs.aarch64-darwin;
  };
}
