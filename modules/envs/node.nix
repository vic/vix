# envs: node tools.
{ yen, ... }:
{
  yen.aspects.env-node = {
    at = yen.helpers.envHas "node";
    env-packages =
      { env, ... }:
      let
        p = env.system.legacyPackages;
      in
      [
        p.nodejs
        p.pnpm
        p.yarn
        p.bun
        p.typescript
      ];
  };
}
