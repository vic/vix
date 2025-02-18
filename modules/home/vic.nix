{
  pkgs,
  inputs,
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
  ];

  home.sessionVariables.EDITOR = "vim";

  home.packages = with pkgs; [
    tree
    vim
    perSystem.nox.default
    perSystem.self.leader
    jujutsu
    fzf
    ripgrep
    bat
    bottom
    htop
  ];

  programs.nh.enable = true;
  programs.home-manager.enable = true;

}
