# gnome-desktop: GDM and GNOME, on hosts that list gnome.
{ hostWhen, ... }:
{
  ren.aspects.gnome-desktop = {
    at = hostWhen (h: builtins.elem "gnome" h.desktops);
    nixos = {
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;
      systemd.services."getty@tty1".enable = false;
      systemd.services."autovt@tty1".enable = false;
    };
  };
}
