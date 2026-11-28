# system: home-manager cli, NH_FILE, and desktop helper tools (linux only).
{ yen, ... }:
{
  yen.aspects.vic-system = {
    at = yen.aspects.vic-headless;
    homeLinux =
      { pkgs, scope, ... }:
      let
        checkout = (yen.helpers.place scope).checkout or null;
      in
      {
        home.packages = [
          pkgs.home-manager
        ];

        # the live checkout; a place without one gets a store copy of the repo (it changes with every edit)
        home.sessionVariables.NH_FILE = if checkout != null then checkout else ../../..;
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
