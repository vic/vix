# system: home-manager cli, NH_FILE, and desktop helper tools (linux only).
{ sven, ... }:
{
  sven.aspects.vic-system = {
    at = sven.aspects.vic-headless;
    homeLinux =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.home-manager
        ];

        home.sessionVariables.NH_FILE = ../../..;
      };
  };

  sven.aspects.vic-desktop-tools = {
    at = sven.aspects.vic-gui;
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
