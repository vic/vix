# kde-desktop: Plasma 6 on SDDM wayland, with avahi, on hosts that list kde.
{ sven, ... }:
{
  sven.aspects.kde-desktop = {
    at = sven.lib.all [
      sven.helpers.linux
      (s: builtins.elem "kde" s.desktops)
    ];
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
