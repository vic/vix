{ inputs, ... }:
{
  imports = with inputs.self.nixosModules; [
    darwin
    nix-features
    vic
    ./static.nix
  ];

  users.users.vic.home = "/v/home";
}
