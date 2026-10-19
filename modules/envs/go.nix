# envs: go tools.
{ ren, pkgsFor, ... }:
{
  ren.aspects.env-go = {
    at = ren.lib.and [
      ren.kinds.env
      (ren.lib.when (s: builtins.elem "go" s.env.langs))
    ];
    env-packages =
      { system, ... }:
      let
        p = pkgsFor system;
      in
      [
        p.go
        p.gopls
      ];
  };
}
