{ pkgs, lib, config, ... } @ a:
let
  sources = import ./sources.nix { inherit pkgs; };
  from = path: self: super:
    import path (a // { inherit sources; pkgs = self; });
in
{
  nixpkgs.overlays = [
    (from ./apps)
    (from ./pkgs)
  ];
}
