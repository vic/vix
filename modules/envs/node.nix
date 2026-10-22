# envs: node tools.
{ ren, ... }:
{
  ren.aspects.env-node = {
    at = ren.lib.and [
      ren.kinds.env
      (ren.lib.when (s: builtins.elem "node" s.env.langs))
    ];
    env-packages =
      { system, ... }:
      let
        p = system.legacyPackages;
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
