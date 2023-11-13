{lib, config, ...}: let
  inherit (lib) pipe id mapAttrs' attrValues;
  inherit (config.vix.lib) dirApply;
in {
  flake.nixosModules = pipe "${config.vix.self}/nixos-features" [
    (dirApply id)
    (mapAttrs' (name: value: { name = "feature-${name}"; inherit value; }))
    (x: x // { all-features.imports = attrValues x; })
  ];
}