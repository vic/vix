top@{ config, ... }: {system, ...}: let 
    nixpkgs = config.vix.inputs.nixpkgs-unstable;
    pkgs = import nixpkgs {
      inherit system;
      config = builtins.trace "NEW NIXPKGS INSTANCE FOR ${system}" import ./config.nix top;
    };
  in pkgs