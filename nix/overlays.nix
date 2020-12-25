{ pkgs, lib, config, ... }:
let
  sources = import ./sources.nix { inherit pkgs; };
  args = { inherit pkgs sources; };
in
{
  nixpkgs.overlays = [
    (self: super: {
      iterm2 = import ./apps/iterm2 args;
      firefox-developer = import ./apps/firefox-developer args;
      tor-browser = import ./apps/tor-browser args;
    })
  ];
}
