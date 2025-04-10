{
  pkgs,
  perSystem,
  osConfig,
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
    ./vic/jujutsu.nix
    ./vic/doom.nix
    ./vic/nvim.nix
    ./vic/dots.nix
  ];

  home.packages =
    (with pkgs; [
      tree
      perSystem.nix-versions.default
      perSystem.nox.default
      perSystem.self.devicon-lookup # for eee
      perSystem.self.leader
      perSystem.self.vic-sops-get
      fzf
      ripgrep # grep
      bat # cat
      bottom
      htop
      yazi # file tui
      eza # ls
      zoxide # cd
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
    ++ (pkgs.lib.optionals
      (builtins.elem osConfig.networking.hostName [
        "mordor"
        "nargun"
      ])
      [
        obsidian # notion
        perSystem.radicle.radicle-full
        perSystem.nix-inspect.default # TODO: enabling it causes GH-action to fail
      ]
    )
    ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [
      pkgs.wl-clipboard
      perSystem.self.copilot-language-server # tab tab tab
    ]);

  programs.nh.enable = true;
  programs.home-manager.enable = true;

}
