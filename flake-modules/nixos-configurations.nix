top@{lib, config, ...}: let
  inherit (lib) mkOption types pipe listToAttrs mapAttrsToList mapAttrs flatten optional literalExample mkDefault length pathExists;
  inherit (config.vix.lib) paths;

  usersOnHost = hostName: pipe config.vix.home-configurations [
    (mapAttrsToList (name: value: optional (value.hostName == hostName) { inherit name value; }))
    flatten
    listToAttrs
  ];

  baseModules = [
    top.config.flake.nixosModules.with-system
    top.config.flake.nixosModules.${"features.all"}
    { _module.args.flakeConfig = top.config; }
  ];

  mkHostModules = cfg: pipe cfg [
    (mapAttrsToList (hostName: cfg: {
      name = "host-${hostName}";
      value = mkHostModule hostName cfg;
    }))
    listToAttrs
  ];

  mkHostModule = hostName: cfg: let
    users = usersOnHost hostName;
    userConfig = homeName: homeCfg: optional (pathExists (paths.homes.user homeName)) {
      users.users.${homeCfg.userName} = paths.homes.user homeName;
    };
    homeConfig = homeName: homeCfg: {config, ...}: {
      home-manager.users.${homeCfg.userName} = {...}: { 
        home.stateVersion = mkDefault config.system.stateVersion;
        imports = [top.config.flake.homeModules.${homeName}];
      };
    };
    usersModules = pipe users [ 
      (mapAttrsToList (homeName: homeCfg: [ 
        [(homeConfig homeName homeCfg)]
        (userConfig homeName homeCfg) 
      ]))
      flatten
    ];
    hm-module = {config, ...}: {
      home-manager.useUserPackages = lib.mkDefault true;
      home-manager.useGlobalPkgs = lib.mkDefault true;
      imports = [ cfg.hmModule ] ++ usersModules;
    };
  in {
    imports = baseModules ++ [ cfg.module ] ++ (optional (users != {}) hm-module); 
    networking.hostName = mkDefault hostName;
  };

  mkHostConfiguration = hostName: cfg: cfg.builder { 
    modules = [ config.flake.nixosModules."host-${hostName}" ]; 
  };

in {
  options.vix.nixos-configurations = mkOption {
    description = "NixOS configurations";
    default = {};
    type = types.lazyAttrsOf (types.submodule ({name, config, ...}: {
      options = {
        builder = mkOption {
          description = "Function used to create the nixos configuration.";
          default = top.config.vix.inputs.nixpkgs-unstable.lib.nixosSystem;
          example = literalExample "inputs.nixpkgs.lib.nixosSystem";
        };

        hmModule = mkOption {
          description = ''
          home-manager's nixos module to include.

          NOTE: If you are using nixpkgs stable release, be sure to also use hm stable release.
          '';
          default = top.config.vix.inputs.home-manager-unstable.nixosModules.home-manager;
          example = literalExample "inputs.home-manager.nixosModules.home-manager";
        };

        module = mkOption {
          description = "Nixos module to load";
          default = paths.nixos.configuration name;
        };

      };
    }));
  };

  config = {
    flake.nixosModules = mkHostModules config.vix.nixos-configurations;
    flake.nixosConfigurations = mapAttrs mkHostConfiguration config.vix.nixos-configurations;
  };
}