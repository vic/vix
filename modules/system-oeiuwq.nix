{ config, pkgs, ... }: {
  system.stateVersion = 4;

  nix.package = pkgs.nixFlakes;
  nix.extraOptions = builtins.readFile ../nix.conf;

  services.nix-daemon.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment.systemPackages = config.pkgSets.oeiuwq;
}
