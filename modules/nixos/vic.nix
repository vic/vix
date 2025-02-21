{ lib, pkgs, ... }:
lib.mkMerge [

  {
    home-manager.backupFileExtension = "backup";

    programs.fish.enable = true;

    users.users.vic = {
      description = "vic";
      shell = pkgs.fish;
    };
  }

  (lib.mkIf pkgs.stdenv.isLinux {
    users.users.vic = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  })

]
