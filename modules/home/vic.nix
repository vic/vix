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
  ];

  home.sessionVariables.EDITOR = "vim";

  home.packages = with pkgs; [
    tree
    vim
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
  ];

  programs.nh.enable = true;
  programs.home-manager.enable = true;

}
