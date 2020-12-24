{ pkgs, lib, config, ... }:
let
  sources = import ./sources.nix { inherit pkgs; };
  args = { inherit pkgs sources; };
in
{
  nixpkgs.overlays = [
    (self: super: {
      iterm2 = import ./apps/iterm2/default.nix args;
    })
  ];
}
