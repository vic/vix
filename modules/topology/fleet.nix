# Root of the scope tree, the flake output sink, and the systems flake outputs are built for.
{
  sven,
  inputs,
  lib,
  ...
}:
let
  pkgs = inputs.nixpkgs.legacyPackages;
in
{
  sven.kinds.fleet = {
    spawns = {
      system = _: sven.system;
      host = _: sven.host;
      mac = _: sven.mac;
      home = _: lib.filterAttrs (_: h: h.on == null) sven.home; # a home with `on` lives under its host
    };
    sinks.out.reduce = sven.lib.reduce.merge;
  };
  sven.fleet.vix = { };
  sven.flake = { out, ... }: out;

  sven.kinds.system.fields = {
    darwin = sven.lib.opt lib.types.bool false;
    # nixpkgs for flake outputs at a system (machines build with their channel)
    legacyPackages = lib.types.raw;
  };
  sven.system.x86_64-linux.legacyPackages = pkgs.x86_64-linux;
  sven.system.aarch64-linux.legacyPackages = pkgs.aarch64-linux;
  sven.system.aarch64-darwin = {
    darwin = true;
    legacyPackages = pkgs.aarch64-darwin;
  };
}
