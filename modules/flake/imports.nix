{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.devshell.flakeModule
  ];

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    devshell.url = "github:numtide/devshell";
    home-manager.url = "github:nix-community/home-manager";

    # for doom-emacs SPC
    blueprint.url = "github:numtide/blueprint";

    # bun2nix systems shim, see follows.nix
    nix-systems.url = "github:nix-systems/default";
  };
}
