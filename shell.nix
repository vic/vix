{ flakePath ? (toString ./.), system ? builtins.currentSystem, pkgSet ? "nix" }:
let flake = builtins.getFlake flakePath;
in flake.packages.${system}.pkgShells.${pkgSet}
