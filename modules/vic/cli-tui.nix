{
  vic.cli-tui = {

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.fzf
          pkgs.ripgrep # grep
          pkgs.bat # cat
          pkgs.bottom
          pkgs.htop
          pkgs.eza # ls
          pkgs.fd # find
          pkgs.jq
          pkgs.television
          pkgs.diffnav
          # pkgs.awrit # browser
        ];
      };

  };
}
