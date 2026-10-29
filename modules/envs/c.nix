# envs: c tools.
{ yen, ... }:
{
  yen.aspects.env-c = {
    at = yen.helpers.envHas "c";
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
