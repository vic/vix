# envs: go tools.
{ ren, ... }:
{
  ren.aspects.env-go = {
    at = ren.lib.and [
      ren.kinds.env
      (ren.lib.when (s: builtins.elem "go" s.env.langs))
    ];
    env-packages =
      { system, ... }:
      let
        p = system.legacyPackages;
      in
      [
        p.go
        p.gopls
      ];
  };
}
