{
  vic.terminals = {

    darwin =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.iterm2 ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.ghostty
          pkgs.wezterm
          pkgs.kitty
        ];
      };

  };
}
