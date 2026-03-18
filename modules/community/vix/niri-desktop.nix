{ lib, ... }:
{
  vix.niri-desktop = {
    nixos =
      { pkgs, ... }:
      {
        programs.niri.enable = true;
        services.displayManager.defaultSession = lib.mkForce "niri";
        environment.systemPackages = [
          pkgs.gnome-keyring
          pkgs.brightnessctl
          pkgs.swaybg
        ];
      };
  };
}
