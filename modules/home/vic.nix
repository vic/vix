{
  pkgs,
  perSystem,
  ...
}:
{

  imports = [
    ./devshells.nix
    ./nix-registry.nix
    ./nix-index.nix
    ./vic/secrets.nix
    ./vic/ssh.nix
    ./vic/fish.nix
    ./vic/git.nix
    ./vic/doom.nix
    ./vic/nvim.nix
    ./vic/dots.nix
  ];

  home.packages =
    (with pkgs; [
      tree
      perSystem.radicle.radicle-full
      perSystem.nix-versions.default
      perSystem.nix-inspect.default
      perSystem.nox.default
      perSystem.self.devicon-lookup # for eee
      perSystem.self.leader
      perSystem.self.copilot-language-server # tab tab tab
      perSystem.self.vic-sops-get
      perSystem.self.jj-fzf
      perSystem.self.lazyjj
      jujutsu # git
      fzf
      ripgrep # grep
      bat # cat
      bottom
      htop
      yazi # file tui
      eza # ls
      zoxide # cd
      obsidian # notion
      fd # find
      lazygit # no magit
      tig # alucard
      cachix
      gh
      jq
      nix-search-cli
      nixd # lsp
      nixfmt-rfc-style
      ispell
    ])
    ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [
      pkgs.wl-clipboard
    ]);

  programs.nh.enable = true;
  programs.home-manager.enable = true;

}
