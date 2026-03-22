{ vic, ... }:
{
  vic.everywhere.includes = [ vic.cli-tools ];
  vic.cli-tools.homeManager =
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
}
