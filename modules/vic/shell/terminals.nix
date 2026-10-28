# terminals: terminal emulators on graphical full homes.
{ sven, ... }:
{
  sven.aspects.terminals = {
    at = sven.lib.all [
      sven.aspects.vic-full
      sven.aspects.vic-gui
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
