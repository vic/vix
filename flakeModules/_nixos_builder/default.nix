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

  osHomeModule = homeName: homeCfg: [({config, ...}: {
    home-manager.users.${homeCfg.userName} = {...}: { 
      home.stateVersion = mkDefault config.system.stateVersion;
      imports = [top.config.flake.homeModules.${homeName}];
    };
  })];

  optionalIfExists = path: module: optional (pathExists path) module;
  osHostModule = homeName: homeCfg: optionalIfExists (paths.homes.hostModule homeName) (paths.homes.hostModule homeName);
  osUserModule = homeName: homeCfg: optionalIfExists (paths.homes.userModule homeName) (args@{pkgs, config, ...}: {
    users.users.${homeCfg.userName} = args2@{...}: { 
      _module.args = args // args2;
      imports = [ (paths.homes.userModule homeName) ];
    };
  });


  homes = hostName: hostCfg: let 
    users = usersOnHost hostName;
    usersModules = pipe users [ 
      (mapAttrsToList (homeName: homeCfg: 
        (osHomeModule homeName homeCfg) ++
        (osUserModule homeName homeCfg) ++
        (osHostModule homeName homeCfg)   
      )) 
      flatten
    ];

    module = {config, ...}: {
      home-manager.useUserPackages = lib.mkDefault true;
      home-manager.useGlobalPkgs = lib.mkDefault true;
      imports = [ hostCfg.hmModule ] ++ usersModules;
    };
  in optional (users != {}) module;

  mkHostModule = hostName: hostCfg: {
    imports = baseModules ++ hostCfg.extraModules ++ [ hostCfg.module ] ++ (homes hostName hostCfg); 
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