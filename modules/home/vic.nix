{pkgs, inputs, ...}: {

  imports = [
    inputs.self.homeModules.vscode-server
  ];

  home.packages = with pkgs; [
    vim
  ];

  programs.fish.enable = true;
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Victor Borja";
    userEmail = "vborja@apache.org";
    signing.format = "ssh";
  };


}