{ lib, pkgs, config, ... }:
let
  cfg = config.vix.features.macos-keys;
in
{

  options.vix.features.macos-keys = with lib; {
    enable = options.mkEnableOption "MacOS keys";
    desktop-keys = import ./desktop-keys-options.nix { inherit lib config; };
  };


  config = lib.mkIf cfg.enable {
    services.keyd.enable = true;
    services.keyd.keyboards.default.ids = [ "*" ]; # apply on all devices
    services.keyd.keyboards.default.settings = lib.mkMerge [
      (import ./caps-is-ctrl-or-esc.nix)
      (import ./lctrl-vim-navigation.nix)
      (import ./macos-keys.nix {
        desktop = cfg.desktop-keys;
        inherit lib pkgs config;
      })
    ];

  };
}
