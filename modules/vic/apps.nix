let
  flake.modules.homeManager.vic.imports = [
    nonBombadil
    anywhere
    linux
  ];

  linux =
    { lib, pkgs, ... }:
    lib.mkIf (pkgs.stdenvNoCC.isLinux) {
      home.packages = [
        pkgs.gparted
        pkgs.wl-clipboard
        # perSystem.self.copilot-language-server # tab tab tab
      ];
    };

  nonBombadil =
    {
      lib,
      pkgs,
      osConfig,
      ...
    }:
    lib.mkIf (osConfig.networking.hostName != "bombadil") {
      home.packages = [
        #perSystem.nox.default
        #perSystem.self.devicon-lookup # for eee
        #perSystem.self.leader
        pkgs.yazi # file tui
        pkgs.zoxide # cd
        pkgs.nix-search-cli
        pkgs.nixd # lsp
        pkgs.nixfmt-rfc-style
        pkgs.ispell
        pkgs.gh
      ];
    };

  anywhere =
    { pkgs, ... }:
    {
      programs.nh.enable = true;
      programs.home-manager.enable = true;

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;

      home.packages = [

        #perSystem.nix-versions.default
        #perSystem.self.vic-sops-get
        pkgs.tree
        pkgs.fzf
        pkgs.ripgrep # grep
        pkgs.bat # cat
        pkgs.bottom
        pkgs.htop
        pkgs.eza # ls
        pkgs.fd # find
        pkgs.lazygit # no magit
        pkgs.tig # alucard
        pkgs.cachix
        pkgs.jq
        pkgs.home-manager
      ];
    };

in
{
  inherit flake;
}
