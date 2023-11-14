top@{ config, ... }: {system, ...}: 
import config.vix.inputs.nixpkgs-unstable {
  inherit system;
  config = {
    allowUnfree = true;
  };
};