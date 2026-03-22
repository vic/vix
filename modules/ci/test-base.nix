{
  inputs,
  lib,
  config,
  den,
  ...
}:
let
  hosts = lib.pipe den.hosts [
    (lib.attrValues)
    (lib.concatMap lib.attrValues)
    (map (host: {
      name = host.name;
      value = lib.attrByPath (host.intoAttr ++ [ "config" ]) null config.flake;
    }))
    (lib.listToAttrs)
  ];
  vicHm = host: host.home-manager.users.vic;

  sort = lib.sort (a: b: a < b);
  show = items: builtins.trace (lib.concatStringsSep " / " (lib.flatten [ items ]));

  pkgNamed =
    name: list:
    let
      filter = p: name == lib.getName p;
      filtered = lib.filter filter list;
      isEmpty = lib.length filtered == 0;
    in
    if isEmpty then null else lib.head filtered;

  _module.args.ci = hosts // {
    inherit
      show
      sort
      vicHm
      pkgNamed
      ;
  };
in
{
  inherit _module;

  flake-file.inputs.nix-unit.url = "github:nix-community/nix-unit";

  imports = [
    inputs.nix-unit.modules.flake.default
  ];

  perSystem.nix-unit = {
    allowNetwork = lib.mkDefault true;
    inputs = lib.mkDefault inputs;
  };

  flake.ci =
    system: test:
    let
      tests = config.flake.tests.systems.${system}.system-agnostic;
      only = if test == "" then tests else lib.attrByPath (lib.splitString "." test) null tests;
    in
    only;
}
