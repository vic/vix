# system: home-manager cli, NH_FILE, and desktop helper tools (linux only).
{ yen, ... }:
{
  yen.aspects.vic-system = {
    at = yen.aspects.vic-headless;
    homeLinux =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.home-manager
        ];

        home.sessionVariables.NH_FILE = ../../..;
      };
  };

  yen.aspects.vic-desktop-tools = {
    at = yen.aspects.vic-gui;
    dots = {
      ".config/fontconfig" = "config/fontconfig";
      ".config/autostart/lxqt-config-touchpad-autostart.desktop" =
        "config/autostart/lxqt-config-touchpad-autostart.desktop";
    };
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
