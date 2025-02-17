{ inputs, pkgs, ... }:
{

  imports = with inputs.self.nixosModules; [
    wsl
    nix-features
    ./static.nix
  ];

  home-manager.backupFileExtension = "backup";
  wsl.defaultUser = "vic";

  programs.fish.enable = true;
  users.users.vic.shell = pkgs.fish;

}
