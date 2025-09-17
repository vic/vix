{ lib, ... }:
{
  flake.modules.nixos.niri-desktop =
    { pkgs, ... }:
    {
      programs.niri.enable = true;
      services.displayManager.defaultSession = lib.mkForce "niri";
      environment.systemPackages = [
        pkgs.brightnessctl
        pkgs.swaybg
      ];
    };
}
