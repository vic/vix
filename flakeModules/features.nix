{lib, config, flake-parts-lib, moduleLocation, ...}: let
  inherit (flake-parts-lib) mkSubmoduleOptions;
  inherit (lib) pipe id mapAttrs' attrValues mkOption mapAttrs types mkMerge;
  inherit (config.vix.lib) dirApply;

  scanFeatures = kind: pipe "${config.vix.self}/features/${kind}" [
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
    (mkOptions "homeModules")
  ];

  config = {
    flake.nixosModules  = scanFeatures "nixos";
    flake.darwinModules = scanFeatures "darwin";
    flake.wslModules    = scanFeatures "wsl";
    flake.homeModules    = scanFeatures "homes";
  };
}