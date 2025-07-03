{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
    inputs.home-manager.flakeModules.home-manager
  ];

  flake-file.inputs = {
    devshell.follows.nixpkgs = "nixpkgs";
    devshell.url = "github:numtide/devshell";

    home-manager.follows.nixpkgs = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
  };
}
