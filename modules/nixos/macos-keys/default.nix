{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.vix.features.macos-keys;
in
{

  options.vix.features.macos-keys = with lib; {
    enable = options.mkEnableOption "MacOS keys";
  };

  config = lib.mkIf cfg.enable {
    services.keyd.enable = true;
    services.keyd.keyboards.default.ids = [ "*" ]; # apply on all devices
    services.keyd.keyboards.default.settings = lib.mkMerge [
      (import ./macos-keys.nix {
        inherit lib pkgs config;
      })
    ];

  };
}
