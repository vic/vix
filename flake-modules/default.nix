top@{lib, config, ...}: let 

  inherit (lib) pipe id mapAttrs' attrValues;

  vix-lib = import ./../lib/_default.nix top;
  inherit (vix-lib) dirApply;

  flake.flakeModules = pipe ./../flake-modules [
     (dirApply id)
     (x: builtins.removeAttrs x ["default"])
     (import ./_lib.nix top vix-lib)
     (import ./_default.nix top)
  ];

in {
  imports = [ 
    flake.flakeModules.default
    ./_vixos.nix # produce outputs on my system
  ];
  inherit flake;
}