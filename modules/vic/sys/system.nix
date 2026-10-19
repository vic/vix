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
