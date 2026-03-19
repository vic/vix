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

  hasPkg = name: list: lib.any (i: name == lib.getName i) list;

  _module.args.ci = hosts // {
    inherit
      show
      sort
      vicHm
      hasPkg
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
