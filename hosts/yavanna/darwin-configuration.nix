{ inputs, ... }:
{
  imports = with inputs.self.nixosModules; [
    darwin
    nix-features
    vic
    ./static.nix
  ];

  nix.enable = false; # nix-daemon is managed by determinate darwin

  users.users.vic.home = "/v/home";
}
