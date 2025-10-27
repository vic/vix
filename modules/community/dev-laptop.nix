{ vix, ... }:
{
  vix.dev-laptop = {
    includes = [
      vix.networking
      vix.bluetooth
      vix.sound
      vix.xserver
      vix.hw-detect
    ];
    nixos = {
      security.rtkit.enable = true;
      powerManagement.enable = true;
    };
  };
}
