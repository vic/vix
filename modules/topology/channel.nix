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
        nixpkgs.url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";
        home-manager = {
          url = "github:nix-community/home-manager";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        darwin = {
          url = "github:LnL7/nix-darwin";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
  };
}
