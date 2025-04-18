{
  lib,
  pkgs,
  perSystem,
  osConfig,
  ...
}:
{

  imports = [
    ./nix-registry.nix
    ./vic/secrets.nix
    ./vic/ssh.nix
    ./vic/fish.nix
    ./vic/git.nix
    ./vic/jujutsu.nix
    ./vic/doom.nix
    ./vic/nvim.nix
    ./vic/dots.nix
  ] ++ (lib.optionals (osConfig.networking.hostName != "bombadil") [
    ./devshells.nix
    ./nix-index.nix
  ]);

  home.packages =
    let
      nonBombadil = lib.optionals (osConfig.networking.hostName != "bombadil") [
        perSystem.nox.default
        perSystem.self.devicon-lookup # for eee
        perSystem.self.leader
        pkgs.yazi # file tui
        pkgs.zoxide # cd
        pkgs.nix-search-cli
        pkgs.nixd # lsp
        pkgs.nixfmt-rfc-style
        pkgs.ispell
      ];

      anywhere = nonBombadil ++ [
        perSystem.nix-versions.default
        perSystem.self.vic-sops-get
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
        pkgs.gh
        pkgs.jq
      ];

      perHost = {
        nargun = [
          # pkgs.obsidian # notion
          perSystem.radicle.radicle-full
          perSystem.nix-inspect.default # TODO: enabling it causes GH-action to fail
        ];
      };

      perPlatform = {
        "x86_64-linux" = [
          pkgs.wl-clipboard
          perSystem.self.copilot-language-server # tab tab tab
        ];
      };

      packages =
        anywhere ++ (perHost.${osConfig.networking.hostName} or [ ]) ++ (perPlatform.${pkgs.system} or [ ]);

    in
    packages;

  programs.nh.enable = true;
  programs.home-manager.enable = true;

}
