# envs: python tools.
{ sven, ... }:
{
  sven.aspects.env-python = {
    at = sven.helpers.envHas "python";
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
