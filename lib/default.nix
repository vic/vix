{ inputs, ... }:
{

  treefmt = pkgs: pkgs.callPackage ./treefmt.nix { inherit inputs; };

}
