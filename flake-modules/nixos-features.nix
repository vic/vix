{lib, config, flake-parts-lib, moduleLocation, ...}: let
  inherit (flake-parts-lib) mkSubmoduleOptions;
  inherit (lib) pipe id mapAttrs' attrValues mkOption mapAttrs types;
  inherit (config.vix.lib) dirApply;

  scanFeatures = dir: pipe dir [
    (dirApply id)
    (mapAttrs' (name: value: { name = "feature-${name}"; inherit value; }))
    (x: x // { ${"feature-all"}.imports = attrValues x; })
  ];

  # stolen from flake-parts/modules/nixosModules.nix
  mkOptions = name: {
    options.flake = mkSubmoduleOptions {
      ${name} = mkOption {
        type = types.lazyAttrsOf types.unspecified;
        default = { };
        apply = mapAttrs (k: v: { _file = "${toString moduleLocation}#${name}.${k}"; imports = [ v ]; });
        description = ''
          NixOS ${name} modules.

          You may use this for reusable pieces of configuration, service modules, etc.
        '';
      };
    };
  }; 

in {
  imports = [
    # nixosModules already defined by flake-parts
    (mkOptions "wslModules")
    (mkOptions "darwinModules")
  ];

  config = {
    flake.nixosModules  = scanFeatures "${config.vix.self}/nixos-features" ;
    flake.wslModules    = scanFeatures "${config.vix.self}/wsl-features" ;
    flake.darwinModules = scanFeatures "${config.vix.self}/darwin-features" ;
  };
}