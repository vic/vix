# Package channels: which nixpkgs, home-manager and nix-darwin a machine builds with.
{
  sven,
  lib,
  inputs,
  ...
}:
let
  t = lib.types;
in
{
  sven.kinds.channel.fields = {
    nixpkgs = t.raw;
    home-manager = t.raw;
    darwin = t.raw;
  };
  sven.channel.unstable = { inherit (inputs) nixpkgs home-manager darwin; };

  sven.aspects.channel-inputs = {
    at = sven.fleet.vix;
    flake-file.inputs = {
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
