# envs: go tools.
{ yen, ... }:
{
  yen.aspects.env-go = {
    at = yen.helpers.envHas "go";
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
