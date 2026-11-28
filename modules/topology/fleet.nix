# Root of the scope tree and the systems flake outputs are built for.
{
  yen,
  types,
  inputs,
  lib,
  ...
}:
let
  pkgs = inputs.nixpkgs.legacyPackages;
in
{
  yen.kinds.root.spawns = {
    system = _: yen.system;
    host = _: yen.host;
    mac = _: yen.mac;
    home = _: lib.filterAttrs (_: h: h.on == null) yen.home; # a home with `on` lives under its host
  };

  yen.kinds.system.fields = {
    darwin = types.opt types.bool false;
    # nixpkgs for flake outputs at a system (machines build with their channel)
    legacyPackages = types.any;
  };
  yen.system.x86_64-linux.legacyPackages = pkgs.x86_64-linux;
  yen.system.aarch64-linux.legacyPackages = pkgs.aarch64-linux;
  yen.system.aarch64-darwin = {
    darwin = true;
    legacyPackages = pkgs.aarch64-darwin;
  };
}
