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
      perSystem.nox.default
      perSystem.self.leader
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
    ])
    ++ (pkgs.lib.optionals pkgs.stdenv.isLinux [
      pkgs.wl-clipboard
    ]);

  programs.nh.enable = true;
  programs.home-manager.enable = true;

}
