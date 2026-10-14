{ ... }:
{
  vic.system.hmLinux =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.gparted
        pkgs.gnome-disk-utility
        pkgs.wl-clipboard-rs
        pkgs.home-manager
      ];

      home.sessionVariables.NH_FILE = ../../..;
    };
}
