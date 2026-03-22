{ vic, ... }:
{
  vic.everywhere.includes = [ vic.terminals ];
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
        ];
      };
  };
}
