{ inputs, pkgs, ... }:
{

  imports = with inputs.self.nixosModules; [
    nix-features
    desktop
    barrier
    vic
    vic-autologin
    ./static.nix
    ./hardware-configuration.nix
  ];

}
