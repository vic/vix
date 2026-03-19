{ vic, ... }:
{
  vic.everywhere.includes = [ vic.terminals ];
  vic.terminals = {

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.ghostty
          pkgs.wezterm
        ];
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
