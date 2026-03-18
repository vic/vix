{ lib, ... }:
{
  vix.xfce-desktop = {
    nixos = {
      services.xserver = {
        enable = true;
        desktopManager = {
          xterm.enable = false;
          xfce.enable = true;
        };
      };
      services.displayManager = {
        defaultSession = lib.mkDefault "xfce";
        enable = true;
      };
    };
  };
}
