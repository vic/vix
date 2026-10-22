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
          url = "github:aanderse/trix";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.cachix
          pkgs.nix-eval-jobs
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
