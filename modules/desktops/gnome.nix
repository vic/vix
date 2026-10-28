# gnome-desktop: GDM and GNOME, on hosts that list gnome.
{ sven, ... }:
{
  sven.aspects.gnome-desktop = {
    at = sven.lib.all [
      sven.helpers.linux
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
