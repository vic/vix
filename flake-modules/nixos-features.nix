{lib, config, ...}: let
  inherit (lib) pipe id mapAttrs' attrValues;
  inherit (config.vix.lib) dirApply;
in {
  flake.nixosModules = pipe "${config.vix.self}/nixos-features" [
    (dirApply id)
    (mapAttrs' (name: value: { name = "features.${name}"; inherit value; }))
    (x: x // { ${"features.all"}.imports = attrValues x; })
  ];
}