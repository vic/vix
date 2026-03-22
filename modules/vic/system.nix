{ vic, ... }:
{
  vic.everywhere.includes = [ vic.system ];
  vic.system.hmLinux =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.gparted
        pkgs.gnome-disk-utility
        pkgs.wl-clipboard-rs
      ];

      home.sessionVariables.NH_FILE = ../..;
    };
}
