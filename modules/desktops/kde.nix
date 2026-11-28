# kde-desktop: Plasma 6 on SDDM wayland, with avahi, on hosts that list yen.desktop.kde.
{ yen, at, ... }:
{
  yen.aspects.kde-desktop = {
    at = yen.kinds.host.where { desktops = at.contains yen.desktop.kde; };
    nixos =
      { pkgs, ... }:
      {
        services.displayManager.sddm.wayland.enable = true;
        services.desktopManager.plasma6.enable = true;
        environment.systemPackages = [ pkgs.kdePackages.karousel ];
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
  };
}
