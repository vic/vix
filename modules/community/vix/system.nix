{ lib, den, ... }:
let
  system = { pkgs, ... }: {
    # usage: (system' inputs.foo).packages.foo
    _module.args.system' = lib.mapAttrs (_: v: v.${pkgs.stdenv.targetPlatform.system});
  };
in
{
  vix.system' = {
    nixos  = system;
    darwin = system;
    user   = system;
    hjem   = system;
    maid   = system;
    homeManager = system;
  };
}
