top@{lib, config, ...}: let
  inherit (lib) mkOption types pipe listToAttrs mapAttrsToList mapAttrs flatten optional literalExample mkDefault length pathExists;
  inherit (config.vix.lib) paths;

  mod = import ./_nixos_builder top {
    kind = "nixos";
    flakeMods = config.flake.nixosModules;
    builder.fn = {
      default = top.config.vix.inputs.nixpkgs-unstable.lib.nixosSystem;
      example = literalExample "inputs.nixpkgs.lib.nixosSystem";
    };

    builder.hm = {
      default = top.config.vix.inputs.home-manager-unstable.nixosModules.home-manager;
      example = literalExample "inputs.home-manager.nixosModules.home-manager";
    };

    builder.extraMods = name: {
      default = []; 
      example = literalExample "[]";
    };

    builder.mod = name: {
      default = paths.nixos.configuration name;
      example = "./nixos-configurations/<your-hostname>/configuration.nix";
    };
  };


in {
  options.vix.nixos-configurations = mod.options.configurations;
  config = {
    flake.nixosModules = mod.config.modules config.vix.nixos-configurations;
    flake.nixosConfigurations = mod.config.configurations config.vix.nixos-configurations;
  };
}