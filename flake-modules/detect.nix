{lib, config, ...}: let 
  inherit (lib) optional pathExists;
  inherit (config.vix.lib) dirApply paths;

  detect = p: dirApply (n: {...}: {
    imports = optional (pathExists (p.default n)) (p.default n);
  }) p.path;

in {
  vix.nixos-configurations  = detect paths.nixos;
  # vix.darwin-configurations = detect paths.darwin;
  vix.wsl-configurations    = detect paths.wsl;
  vix.home-configurations   = detect paths.homes;
}