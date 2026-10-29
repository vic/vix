# envs: the env kind (a dev environment per system, and per user on a machine that lists it), its package pool and its two consumers.
{
  yen,
  lib,
  inputs,
  ...
}:
let
  inherit (yen.lib) opt all within;
  inherit (yen.helpers) listOf enum place;
  envs = opt (listOf yen.kinds.env) [ ];
  # an env scope carries the system it is built for: `{ env, ... }: env.system.legacyPackages`
  onSystem = system: e: e // { inherit system; };
in
{
  # machines and homes list the envs their users get
  yen.kinds.machine.fields.envs = envs;
  yen.kinds.home.fields.envs = envs;
  yen.kinds.system.spawns.env = s: lib.mapAttrs (_: onSystem s) yen.env; # one env scope per system: its devshell
  # a user on a machine that lists an env gets its own scope of it: its packages land in the user's home
  yen.kinds.user.spawns.env =
    s:
    let
      p = place s;
    in
    if p == null then
      { }
    else
      lib.listToAttrs (map (e: lib.nameValuePair e.name (onSystem p.system e)) p.envs);

  yen.kinds.env = {
    fields.langs = listOf (enum [
      "nix"
      "rust"
      "go"
      "node"
      "python"
      "c"
    ]);
    # tools give lists of derivations; the env's devshell reads the pool, and a user's env gives it to the home.
    # `env` keeps one element per env
    sinks.env-packages.homeManager = { env, env-packages, ... }: { home.packages = builtins.concatLists env-packages; };
  };

  yen.aspects.devshell = {
    at = all [
      yen.kinds.env
      (within yen.kinds.system)
    ];
    flake-file.inputs.devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshells =
      { env, env-packages, ... }:
      {
        ${env.name} = (import inputs.devshell { nixpkgs = env.system.legacyPackages; }).mkShell {
          name = env.name;
          packages = builtins.concatLists env-packages;
        };
      };
  };
}
