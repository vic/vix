{
  vix.kde-desktop.nixos =
    { pkgs, ... }:
    {
      services.displayManager.sddm.wayland.enable = true;
      services.desktopManager.plasma6.enable = true;

      environment.systemPackages = [
        pkgs.kdePackages.karousel
      ];

      services.avahi = {
        nssmdns4 = true;
        enable = true;
        publish = {
          enable = true;
          userServices = true;
          domain = true;
        };
      };
    };
}
