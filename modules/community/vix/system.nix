{ lib, ... }:
let
  # usage: (system' inputs.foo).packages.foo
  system' = pkgs: lib.mapAttrs (_: v: v.${pkgs.stdenv.targetPlatform.system});
in
{
  vix.system' =
    { class, aspect-chain }:
    {
      ${class} =
        { pkgs, ... }:
        {
          _module.args.system' = system' pkgs;
        };
    };
}
