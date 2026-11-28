# gnome-desktop: GDM and GNOME, on hosts that list yen.desktop.gnome.
{ yen, at, ... }:
{
  yen.aspects.gnome-desktop = {
    at = yen.kinds.host.where { desktops = at.contains yen.desktop.gnome; };
    nixos = {
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;
    };
  };
}
