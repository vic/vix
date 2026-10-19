# envs: python tools.
{ ren, pkgsFor, ... }:
{
  ren.aspects.env-python = {
    at = ren.lib.and [
      ren.kinds.env
      (ren.lib.when (s: builtins.elem "python" s.env.langs))
    ];
    env-packages =
      { system, ... }:
      let
        p = pkgsFor system;
      in
      [
        p.python3
        p.uv
      ];
  };
}
