{
  lib,
  pkgs,
  ...
}:
{

  home-manager.backupFileExtension = "backup";

  programs.fish.enable = true;

  fonts.packages = with pkgs.nerd-fonts; [
    victor-mono
    jetbrains-mono
    inconsolata
  ];

  users.users.vic = {
    description = "vic";
    shell = pkgs.fish;
  };

  imports = [
    (lib.mkIf pkgs.stdenv.isLinux {
      users.users.vic = {
        isNormalUser = true;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };
    })
  ];
}
