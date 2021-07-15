{ config, lib, pkgs, ... }: {

  home-manager.users.vic.programs.ssh = {
    enable = true;
    controlMaster = "yes";
    controlPersist = "10m";
    forwardAgent = true;
  };

}
