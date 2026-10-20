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

  ren.kinds.channel = {
    nixpkgs = t.raw;
    home-manager = t.raw;
    darwin = t.raw;
  };
  ren.channel.unstable = { inherit (inputs) nixpkgs home-manager darwin; };

  ren.aspects.channel-inputs = {
    at = ren.fleet.vix;
    flake-inputs =
      { ... }:
      {
        nixpkgs.url = "github:nixos/nixpkgs/8edc0c72e3a38faf5434e40d1f19431125fe4b30";
        home-manager = {
          url = "github:nix-community/home-manager/c58f54c733a7894d84fa2fdff26cc12088c4b78c";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        darwin = {
          url = "github:LnL7/nix-darwin/4cff07de74b50e64bdd68cd4e722ab5b6b35ee48";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
  };
}
