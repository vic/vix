# nix: nix tooling packages.
{ sven, inputs, ... }:
{
  sven.aspects.nix-tools = {
    at = sven.aspects.vic-headless;
    flake-file.inputs.trix = {
      url = "github:aanderse/trix";
      inputs.nixpkgs.follows = "nixpkgs";
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
          (sven.helpers.perSystem pkgs inputs.trix).packages.trix
        ];
      };
  };
}
