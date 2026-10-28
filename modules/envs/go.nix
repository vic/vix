# envs: go tools.
{ sven, ... }:
{
  sven.aspects.env-go = {
    at = sven.helpers.envHas "go";
    env-packages =
      { env, ... }:
      let
        p = env.system.legacyPackages;
      in
      [
        p.go
        p.gopls
      ];
  };
}
