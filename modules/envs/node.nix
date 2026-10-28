# envs: node tools.
{ sven, ... }:
{
  sven.aspects.env-node = {
    at = sven.helpers.envHas "node";
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
