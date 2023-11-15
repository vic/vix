top@{lib, config, ...}: let
  inherit (lib) mkOption types pipe listToAttrs mapAttrsToList mapAttrs flatten optional literalExample mkDefault length pathExists;
  inherit (config.vix.lib) paths;


  mod = import ./_nixos_builder top {
    kind = "wsl";

    builder.fn = {
      default = top.config.vix.inputs.nixpkgs-stable.lib.nixosSystem;
      example = literalExample "inputs.nixpkgs.lib.nixosSystem";
    };
    
    builder.hm = {
      default = top.config.vix.inputs.home-manager-stable.nixosModules.home-manager;
      example = literalExample "inputs.home-manager.nixosModules.home-manager";
    };

    builder.extraMods = name: {
      default = [
        top.config.vix.inputs.nixos-wsl-stable.nixosModules.default
        { wsl.enable = true; }
      ]; 
      example = literalExample "[]";
    };
  };


in {
  options.vix.wsl-configurations = mod.options.configurations;
  config = {
    flake.wslModules = mod.config.modules config.vix.wsl-configurations;
    flake.nixosConfigurations = mod.config.configurations config.vix.wsl-configurations;
  };
}