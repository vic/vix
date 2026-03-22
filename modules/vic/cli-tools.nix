{ vic, ... }:
{
  vic.everywhere.includes = [ vic.cli-tools ];
  vic.cli-tools.homeManager =
    { pkgs, self', ... }:
    {
      programs.nh.enable = true;
      home.packages = [
        pkgs.fzf
        pkgs.ripgrep
        pkgs.bat
        pkgs.bottom
        pkgs.htop
        pkgs.eza
        pkgs.fd
        pkgs.cachix
        pkgs.jq
        pkgs.helix
        pkgs.television
        pkgs.dust
        pkgs.duf
        pkgs.procs
        pkgs.sd
        pkgs.tokei
        pkgs.hyperfine
        pkgs.glow
        pkgs.tealdeer
        pkgs.ouch
        pkgs.difftastic
        pkgs.zellij
        self'.packages.vic-sops-get
        self'.packages.vic-sops-rotate
      ];
    };
}
