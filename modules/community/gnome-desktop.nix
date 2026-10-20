# gnome-desktop: GDM and GNOME, on hosts that list gnome.
{ ren, ... }:
{
  ren.aspects.gnome-desktop = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: builtins.elem "gnome" s.host.desktops))
    ];
    nixos = {
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;
    };
  };
}
