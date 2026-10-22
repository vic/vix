# envs: c tools.
{ ren, ... }:
{
  ren.aspects.env-c = {
    at = ren.lib.and [
      ren.kinds.env
      (ren.lib.when (s: builtins.elem "c" s.env.langs))
    ];
    env-packages =
      { system, ... }:
      let
        p = system.legacyPackages;
      in
      [
        p.gcc
        p.gnumake
        p.pkg-config
      ];
  };
}
