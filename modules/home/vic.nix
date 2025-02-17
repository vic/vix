{pkgs, inputs, perSystem, ...}: {

  imports = [
    inputs.self.homeModules.vscode-server
  ];

  home.packages = with pkgs; [
    devenv
    tree
    vim
    perSystem.devshell.default
    perSystem.nox.default
    perSystem.self.leader
  ];

  programs.nh.enable = true;
  programs.direnv.enable = true;
  programs.fish.enable = true;
  programs.home-manager.enable = true;

  home.file.".config/fish/conf.d/init-leader.fish".source = "${inputs.cli-leader.outPath}/assets/leader.fish.sh";


  programs.git = {
    enable = true;
    userName = "Victor Borja";
    userEmail = "vborja@apache.org";
    signing.format = "ssh";
  };


}