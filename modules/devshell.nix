{ lib, config, ... }:
let
  devshell = pkgs: pkgs.mkShell { buildInputs = apps pkgs; };

  apps = pkgs: lib.attrValues (lib.mapAttrs (n: f: f pkgs) config.dev.apps);
in
{

  options.dev = {
    sh = lib.mkOption {
      type = lib.types.raw;
      default = devshell;
    };
    apps = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.functionTo lib.types.package);
    };
  };

}
