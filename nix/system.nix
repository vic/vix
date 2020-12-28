{ pkgs, ... }:

{
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = builtins.readFile ../nix.conf;
  services.nix-daemon.enable = true;
  environment.systemPackages = with pkgs; [
    nixFlakes
    direnv
    home-manager
  ];
  system.stateVersion = 4;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
