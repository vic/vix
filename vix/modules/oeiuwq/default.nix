{ config, pkgs, lib, vix, ... }: {

  imports = [ ./intel-overlay.nix ./link-jvm.nix ];

  system.stateVersion = 4;

  nix.extraOptions = builtins.readFile "${vix}/nix.conf";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment.systemPackages = config.pkgSets.oeiuwq;

  services.nix-daemon.enable = true;
  services.lorri.enable = true;

}
