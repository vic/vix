{ vic, ... }:
{
  vic.system.includes = [ vic.desktop-tools ];

  vic.system.hmLinux =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.home-manager
      ];

      home.sessionVariables.NH_FILE = ../../..;
    };

  vic.desktop-tools.hmLinux =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.gparted
        pkgs.gnome-disk-utility
        pkgs.wl-clipboard-rs
      ];
    };
}
