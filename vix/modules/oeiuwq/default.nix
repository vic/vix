{ config, pkgs, lib, vix, vix-lib, ... }: {

  imports = [ ./link-jvm.nix ];

  system.stateVersion = 4;

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = builtins.readFile "${vix}/nix.conf";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment.systemPackages = config.pkgSets.oeiuwq;

  services.nix-daemon.enable = true;
  services.lorri.enable = true;

}
