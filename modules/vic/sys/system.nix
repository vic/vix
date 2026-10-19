# system: home-manager cli, NH_FILE, and desktop helper tools (linux only).
{ vicAt, ... }:
{
  ren.aspects.vic-system = {
    at = vicAt.core;
    homeLinux =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.home-manager
        ];

        home.sessionVariables.NH_FILE = ../../..;
      };
  };

  ren.aspects.vic-desktop-tools = {
    dots = {
      ".config/fontconfig" = "config/fontconfig";
      ".config/autostart/lxqt-config-touchpad-autostart.desktop" =
        "config/autostart/lxqt-config-touchpad-autostart.desktop";
    };
    at = vicAt.desktop;
    homeLinux =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.gparted
          pkgs.gnome-disk-utility
          pkgs.wl-clipboard-rs
        ];
      };
  };
}
