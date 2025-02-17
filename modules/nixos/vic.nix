{ pkgs, ... }:
{
  home-manager.backupFileExtension = "backup";

  programs.fish.enable = true;

  users.users.vic = {
    isNormalUser = true;
    description = "vic";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

}
