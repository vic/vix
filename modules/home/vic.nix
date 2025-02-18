{
  pkgs,
  inputs,
  perSystem,
  ...
}:
{

  imports = [
    inputs.nix-index-database.hmModules.nix-index
    ./vic/secrets.nix
    ./vic/devshells.nix
    ./vic/nix-registry.nix
    ./vic/ssh.nix
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
  programs.fish.enable = true;
  programs.home-manager.enable = true;
  programs.nix-index.enable = true;
  programs.nix-index.enableFishIntegration = true;
  programs.nix-index-database.comma.enable = true;

  home.file.".config/fish/conf.d/init-leader.fish".source =
    "${inputs.cli-leader.outPath}/assets/leader.fish.sh";

  home.file.".nix-flake".source = inputs.self.outPath;

  programs.git = {
    enable = true;
    userName = "Victor Borja";
    userEmail = "vborja@apache.org";
    signing.format = "ssh";
  };

}
