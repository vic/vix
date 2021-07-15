{ config, pkgs, lib, vix-lib, ... }: {

  imports = [ ./activation-diff.nix ./link-jvm.nix ];

  system.stateVersion = 4;

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = builtins.readFile ../../nix.conf;

  services.nix-daemon.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment.systemPackages = config.pkgSets.oeiuwq;

}
