# envs: the env kind (a dev environment per system), its package pool channel, and the two consumers.
{
  ren,
  lib,
  pkgsFor,
  place,
  ...
}:
{
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
              m = place r;
            in
            m != null
            && m.system.name == e.system.name
            && builtins.elem e.env.name (map (x: x.name) (m.envs or [ ]))
          ))
        ])
      ];
  };

  ren.channels.devshells = {
    fold = ren.lib.fold.attrs;
    at = ren.kinds.env;
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
    devshells =
      {
        env,
        system,
        env-packages,
        ...
      }:
      {
        ${env.name} = (pkgsFor system).mkShell { packages = builtins.concatLists env-packages; };
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
