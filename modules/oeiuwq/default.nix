{ config, pkgs, lib, ... }: {
  system.stateVersion = 4;

  nix.package = pkgs.nixFlakes;
  nix.extraOptions = builtins.readFile ../../nix.conf;

  services.nix-daemon.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment.systemPackages = config.pkgSets.oeiuwq;

  system.activationScripts.preActivation.text = lib.mkMerge [''
    ${pkgs.nixUnstable}/bin/nix store \
        --experimental-features 'nix-command' \
        diff-closures /run/current-system "$systemConfig"
  ''];

}
