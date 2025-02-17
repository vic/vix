{
  pkgs,
  inputs,
  perSystem,
  ...
}:
{

  imports = [
    inputs.self.homeModules.vscode-server

  ];

  home.packages = with pkgs; [
    tree
    vim
    perSystem.nox.default
    perSystem.self.leader
  ];

  programs.nh.enable = true;
  programs.fish.enable = true;
  programs.home-manager.enable = true;

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
