{ config, lib, pkgs, USER, ... }: {

  home-manager.users.${USER}.programs.ssh = {
    enable = true;
    controlMaster = "yes";
    controlPersist = "10m";
    forwardAgent = true;
  };

}
