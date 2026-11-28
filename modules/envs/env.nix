# envs: the env kind (a dev environment per system, and per user on a place that lists it).
{
  yen,
  at,
  types,
  reduce,
  lib,
  inputs,
  ...
}:
let
  inherit (yen.helpers) place;
  onSystem = system: e: e // { inherit system; };
in
{
  yen.kinds.place.fields.envs = types.opt (types.listOf yen.kinds.env) [ ];
  yen.kinds.system.spawns.env = s: lib.mapAttrs (_: onSystem s) yen.env;
  yen.kinds.user.spawns.env =
    s:
    (
      p:
      if p == null then
        { }
      else
        lib.listToAttrs (map (e: lib.nameValuePair e.name (onSystem p.system e)) p.envs)
    )
      (place s);

  yen.kinds.env = {
    fields.system = types.maybe yen.kinds.system;
    sinks.env-packages = {
      reduce = reduce.list;
      into.homeManager =
        { env-packages, ... }:
        {
          home.packages = builtins.concatLists env-packages;
        };
    };
  };

  yen.aspects.devshell = {
    at = at.all [
      yen.kinds.env
      (at.under yen.kinds.system)
    ];
    flake-file.inputs.devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshells =
      { env, env-packages, ... }:
      {
        ${env.name} = (import inputs.devshell { nixpkgs = env.system.legacyPackages; }).mkShell {
          inherit (env) name;
          packages = builtins.concatLists env-packages;
        };
      };
  };
}
