{lib, config, ...}: let 
  inherit (lib) optional pathExists;
  inherit (config.vix.lib) dirApply paths;
in {
  vix.nixos-configurations = dirApply (n: {...}: {
    imports = optional (pathExists (paths.nixos.default n)) (paths.nixos.default n);
  }) paths.nixos.path;
  vix.home-configurations = dirApply (n: {...}: {
    imports = optional (pathExists (paths.homes.default n)) (paths.homes.default n);
  }) paths.homes.path;
}