{

  vix.niri-desktop.nixos =
    { pkgs, lib, ... }:
    {
      programs.niri.enable = true;
      services.displayManager.defaultSession = lib.mkForce "niri";
      environment.systemPackages = [
        pkgs.brightnessctl
        pkgs.swaybg
      ];
    };

}
