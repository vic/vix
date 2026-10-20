# terminals: terminal emulators on graphical full homes.
{ ren, ... }:
{
  ren.aspects.terminals = {
    dots = {
      ".config/wezterm" = "config/wezterm";
      ".config/ghostty" = "config/ghostty";
    };
    at = ren.lib.and [
      ren.aspects.vic-full
      ren.aspects.vic-gui
    ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.wezterm ];
      };
    homeLinux =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.ghostty ];
      };
    homeDarwin = { pkgs, ... }: {
      home.packages = [
        pkgs.iterm2
        pkgs.ghostty-bin
      ];
    };
  };
}
