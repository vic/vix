{ lib, den, ... }:
let
  # usage: (system' inputs.foo).packages.foo
  system = pkgs: lib.mapAttrs (_: v: v.${pkgs.stdenv.targetPlatform.system});
in
{
  vix.system' = { class, aspect-chain }: lib.optionalAttrs (class != "os") {
    ${class} = { pkgs, ... }: {
      _module.args.system' = system pkgs;
    };
  };
}
