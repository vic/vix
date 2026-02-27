{
  lib,
  config,
  ...
}:
let
  devShell = {
    sh = lib.mkOption {
      type = lib.types.raw;
      default = pkgs: pkgs.mkShell { buildInputs = config.dev.apps pkgs; };
    };
    apps = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
    };
  };

in
{
  options.dev = devShell;
  config.dev.apps =
    pkgs: with pkgs; [
      nh
      sops
      npins
    ];
}
