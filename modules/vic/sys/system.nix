# system: home-manager cli, NH_FILE, and desktop helper tools (linux only).
{ ren, ... }:
{
  ren.aspects.vic-system = {
    at = ren.aspects.vic-headless;
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
    at = ren.aspects.vic-gui;
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
