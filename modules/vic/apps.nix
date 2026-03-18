{ inputs, ... }:
let
  linux =
    { lib, pkgs, ... }:
    lib.mkIf (pkgs.stdenvNoCC.isLinux) {
      home.packages = [
        pkgs.gparted
        pkgs.wl-clipboard
        pkgs.copilot-language-server
        pkgs.aider-chat
        pkgs.qutebrowser
        pkgs.multimarkdown
        pkgs.gemini-cli-bin
        inputs.helium.packages.${pkgs.stdenvNoCC.hostPlatform.system}.default
      ];
    };

  nonBombadil =
    {
      lib,
      pkgs,
      osConfig,
      ...
    }:
    lib.mkIf (pkgs.stdenvNoCC.isLinux && osConfig.networking.hostName != "bombadil") {
      home.packages = [
        pkgs.yazi
        pkgs.zoxide
        pkgs.nix-search-cli
        pkgs.nixd
        pkgs.nixfmt
        pkgs.ispell
        pkgs.gh
      ];
    };

  anywhere =
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
        selfpkgs.vic-sops-get
        selfpkgs.vic-sops-rotate
      ];
    };
in
{
  flake-file.inputs.helium.url = "github:vikingnope/helium-browser-nix-flake";

  vic.apps.homeManager.imports = [
    nonBombadil
    anywhere
    linux
  ];
}
