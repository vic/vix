# terminals: terminal emulators on graphical full homes.
{ yen, ... }:
{
  yen.aspects.terminals = {
    at = yen.lib.all [
      yen.aspects.vic-full
      yen.aspects.vic-gui
    ];
    dots = {
      ".config/wezterm" = "config/wezterm";
      ".config/ghostty" = "config/ghostty";
    };
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
    homeDarwin =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.iterm2
          pkgs.ghostty-bin
        ];
      };
  };
}
