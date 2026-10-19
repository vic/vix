# terminals: terminal emulators on graphical full homes.
{ ren, vicAt, ... }:
{
  ren.aspects.terminals = {
    at = ren.lib.and [
      vicAt.full
      vicAt.desktop
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
    # homeDarwin (iterm2, ghostty-bin) omitted: a key landing in no scope is an eval error and no macs exist yet.
  };
}
