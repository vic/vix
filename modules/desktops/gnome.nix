# gnome-desktop: GDM and GNOME, on hosts that list gnome.
{ yen, ... }:
{
  yen.aspects.gnome-desktop = {
    at = yen.lib.all [
      yen.helpers.linux
      (s: builtins.elem "gnome" s.desktops)
    ];
    nixos = {
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;
    };
  };
}
