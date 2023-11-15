top@{lib, config, ...}: {kind, builder}: let
  inherit (lib) mkOption types pipe listToAttrs mapAttrsToList mapAttrs flatten optional literalExample mkDefault length pathExists;
  inherit (config.vix.lib) paths;

  flakeMods = config.flake."${kind}Modules";
  baseModules = import ./base-modules.nix top;

  usersOnHost = hostName: pipe config.vix.home-configurations [
    (mapAttrsToList (name: value: optional (value.hostName == hostName) { inherit name value; }))
    flatten
    listToAttrs
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
    imports = baseModules ++ cfg.extraModules ++ [ cfg.module ] ++ (optional (users != {}) hm-module); 
    networking.hostName = mkDefault hostName;
  };

  mkHostConfiguration = hostName: cfg: cfg.builder { 
    modules = [ flakeMods."host-${hostName}" ]; 
  };

in {
  options.configurations = mkOption {
    description = "NixOS configurations";
    default = {};
    type = types.lazyAttrsOf (types.submodule (import ./options.nix top { inherit builder kind; }));
  };

  config = {
    modules = mkHostModules;
    configurations = mapAttrs mkHostConfiguration;
  };
}