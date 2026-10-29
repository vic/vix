# envs: nix tools.
{ yen, ... }:
{
  yen.aspects.env-nix = {
    at = yen.helpers.envHas "nix";
    env-packages =
      { env, ... }:
      let
        p = env.system.legacyPackages;
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
