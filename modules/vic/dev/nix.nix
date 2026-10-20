# nix: nix tooling packages.
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{
  ren.aspects.nix-tools = {
    at = ren.aspects.vic-headless;
    flake-inputs =
      { ... }:
      {
        trix = {
          url = "github:aanderse/trix/222013b234cd8db2314f8fca4fff9ac5be5e69f5";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.cachix
          pkgs.nix-search-cli
          pkgs.nixd
          pkgs.nixfmt
          pkgs.statix
          pkgs.tree-sitter
          pkgs.zig
          pkgs.nix-run
          (vix.perSystem pkgs inputs.trix).packages.trix
        ];
      };
  };
}
