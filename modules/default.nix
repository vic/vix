{ pkgs, ... }: {
  nix.package = pkgs.nixFlakes;
  services.nix-daemon.enable = true;
  system.stateVersion = 4;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
