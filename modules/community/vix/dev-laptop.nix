{ vix, ... }:
{
  vix.dev-laptop = {
    includes = [
      vix.networking
      vix.bluetooth
      vix.sound
      vix.xserver
      vix.hw-detect
      vix.macos-keys
    ];
    nixos = {
      security.rtkit.enable = true;
      powerManagement.enable = true;
    };
  };
}
