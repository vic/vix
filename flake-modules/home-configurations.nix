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
          description = "Nixos module to configure the user at system (eg groups)";
          default = paths.homes.user name;
        };
        module = mkOption {
          description = "home-manager module to configure the user home.";
          default = paths.homes.configuration name;
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