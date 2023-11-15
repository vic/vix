top@{lib, config, ...}: let

  inherit (builtins) match;
  inherit (lib) mkOption types elemAt mapAttrs mapAttrs' literalExample pipe mapAttrsToList; 
  inherit (config.vix.lib) paths;

  mkHomeModule = (homeName: homeCfg: homeCfg.module);
  mkHomeConfiguration = homeName: homeCfg: homeCfg.builder {
    modules = [ top.config.flake.homeModules.${homeName} ];
    pkgs = homeCfg.pkgs;
  };

in { 
  options.vix.home-configurations = mkOption {
    description = "home-manager configurations.";
    type = types.lazyAttrsOf (types.submodule ({name, config, ...}: {
      options = {
        builder = mkOption {
          description = "function used to build a hm-configuration";
          example = literalExample "inputs.home-manager.lib.homeManagerConfiguration";
          default = top.config.vix.inputs.home-manager-unstable.lib.homeManagerConfiguration;
        };
        userName = mkOption { 
          default = elemAt (match "([^@]+)@(.*)" name) 0;
        };
        hostName = mkOption {
          default = elemAt (match "([^@]+)@(.*)" name) 1;
        };
        userModule = mkOption {
          description = "nixos user module";
          default = paths.homes.userModule name;
        };
        hostModule = mkOption {
          description = "nixos system module";
          default = paths.homes.hostModule name;
        };
        module = mkOption {
          description = "home-manager module to configure the user home.";
          default = paths.homes.default name;
        };
        pkgs = mkOption {
          description = "nixpkgs instance to use for homeConfiguration";
          default = null;
        };
      };
    }));
  };

  config = {
    flake.homeModules = mapAttrs mkHomeModule config.vix.home-configurations;
    flake.homeConfigurations = mapAttrs mkHomeConfiguration config.vix.home-configurations;
  };
}