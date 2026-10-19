# envs: nix tools.
{ ren, pkgsFor, ... }:
{
  ren.aspects.env-nix = {
    at = ren.lib.and [
      ren.kinds.env
      (ren.lib.when (s: builtins.elem "nix" s.env.langs))
    ];
    env-packages =
      { system, ... }:
      let
        p = pkgsFor system;
      in
      [
        p.nixd
        p.nixfmt
        p.nil
        p.npins
        p.nix-unit
        p.nh
        p.cachix
        p.just
        p.statix
        p.deadnix
      ];
  };
}
