{ ... }:
{
  vic.terminals = {
    hm =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.wezterm
        ];
      };

    hmLinux =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.ghostty ];
      };

    hmDarwin =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.iterm2
          pkgs.ghostty-bin
        ];
      };
  };
}
