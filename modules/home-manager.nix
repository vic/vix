{ den, ... }:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";
  flake-file.inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  den.default.includes = [ den._.home-manager ];
}
