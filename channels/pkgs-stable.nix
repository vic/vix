top@{ config, ... }: {system, ...}: 
import config.vix.inputs.nixpkgs-stable {
  inherit system;
  config = {
    allowUnfree = true;
  };
};