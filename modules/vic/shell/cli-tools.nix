# cli-tools: everyday command line packages and nh.
{ yen, ... }:
{
  yen.aspects.cli-tools = {
    at = yen.aspects.vic-headless;
    dots = {
      ".config/btop" = "config/btop";
      ".config/bottom" = "config/bottom";
    };
    homeManager =
      { pkgs, ... }:
      {
        programs.nh.enable = true;
        home.packages = [
          pkgs.bat
          pkgs.bottom
          pkgs.duf
          pkgs.dust
          pkgs.eza
          pkgs.fd
          pkgs.fzf
          pkgs.glow
          pkgs.helix
          pkgs.htop
          pkgs.ispell
          pkgs.multimarkdown
          pkgs.ouch
          pkgs.procs
          pkgs.ripgrep
          pkgs.sd
          pkgs.tealdeer
          pkgs.television
          pkgs.tokei
          pkgs.yazi
          pkgs.zellij
          pkgs.zoxide
        ];
      };
  };
}
