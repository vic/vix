# envs: python tools.
{ yen, ... }:
{
  yen.aspects.env-python = {
    at = yen.helpers.envHas "python";
    env-packages =
      { env, ... }:
      let
        p = env.system.legacyPackages;
      in
      [
        p.python3
        p.uv
      ];
  };
}
