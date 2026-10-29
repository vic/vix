# cli-tools: everyday command line packages, nh and zoxide.
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
        # z learns dirs; --cmd cd makes plain cd use it
        programs.zoxide = {
          enable = true;
          enableFishIntegration = true;
          options = [ "--cmd cd" ];
        };
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
          pkgs.xh
          pkgs.yazi
          pkgs.zellij
        ];
      };
  };
}
