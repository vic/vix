# envs: the env kind (a dev environment per system), its package pool channel, and the two consumers.
{
  ren,
  lib,
  inputs,
  ...
}:
let
  vix = ren.helpers;
in
{
  # machines and homes list the envs their users get (merges with the kind owners, v33)
  ren.kinds.machine.envs = vix.opt (lib.types.listOf ren.kinds.env) [ ];
  ren.kinds.home.envs = vix.opt (lib.types.listOf ren.kinds.env) [ ];
  ren.kinds.system.below = [ ren.kinds.env ]; # one env scope per system
  ren.kinds.env.langs = lib.types.listOf (
    lib.types.enum [
      "nix"
      "rust"
      "go"
      "node"
      "python"
      "c"
    ]
  );

  # tools emit derivations; the pool is read by the env's devshell and by users whose machine lists the env.
  ren.channels.env-packages = {
    fold = ren.lib.fold.list;
    at = ren.kinds.env;
    to =
      e:
      ren.lib.anyOf [
        e
        (ren.lib.and [
          ren.kinds.user
          (ren.lib.when (
            r:
            let
              m = vix.place r;
            in
            m != null && m.system.name == e.system.name && builtins.elem e.env.name (map (x: x.name) m.envs)
          ))
        ])
      ];
  };

  ren.channels.devshells = {
    fold = ren.lib.fold.attrs;
    at = ren.lib.anyOf [
      ren.kinds.env
      ren.kinds.system
    ]; # env shells, and the maintainer shell (features/devshell.nix)
    to =
      e:
      ren.lib.and [
        ren.kinds.system
        (ren.lib.anyOf [
          e
          (ren.lib.has e)
        ])
      ];
    into = { system, ... }: s: { devShells.${system.name} = s; };
  };

  ren.aspects.devshell = {
    at = ren.kinds.env;
    flake-inputs =
      { ... }:
      {
        devshell = {
          url = "github:numtide/devshell";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    devshells =
      {
        env,
        system,
        env-packages,
        ...
      }:
      {
        ${env.name} = (import inputs.devshell { nixpkgs = system.legacyPackages; }).mkShell {
          name = env.name;
          packages = builtins.concatLists env-packages;
        };
      };
  };

  ren.aspects.env-home = {
    at = ren.kinds.user;
    homeManager =
      { env-packages, ... }:
      {
        home.packages = builtins.concatLists env-packages;
      };
  };
}
