# kde-desktop: Plasma 6 on SDDM wayland, with avahi, on hosts that list kde.
{ ren, ... }:
{
  ren.aspects.kde-desktop = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: builtins.elem "kde" s.host.desktops))
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
