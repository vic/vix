{ vic, inputs, ... }:
{
  vic.everywhere.includes = [ vic.cli-tools ];
  vic.cli-tools.homeManager =
    { pkgs, ... }:
    let
      selfpkgs = inputs.self.packages.${pkgs.stdenvNoCC.hostPlatform.system};
    in
    {
      programs.nh.enable = true;
      programs.home-manager.enable = true;
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
        pkgs.home-manager
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
        selfpkgs.vic-sops-get
        selfpkgs.vic-sops-rotate
      ];
    };
}
