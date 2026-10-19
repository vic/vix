# kde-desktop: Plasma 6 on SDDM wayland, with avahi, on hosts that list kde.
{ hostWhen, ... }:
{
  ren.aspects.kde-desktop = {
    at = hostWhen (h: builtins.elem "kde" h.desktops);
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
