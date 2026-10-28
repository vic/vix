# envs: c tools.
{ sven, ... }:
{
  sven.aspects.env-c = {
    at = sven.helpers.envHas "c";
    env-packages =
      { env, ... }:
      let
        p = env.system.legacyPackages;
      in
      [
        p.gcc
        p.gnumake
        p.pkg-config
      ];
  };
}
