# nix: nix tooling packages.
{ vicAt, ... }:
{
  ren.aspects.nix-tools = {
    at = vicAt.headless;
    flake-inputs =
      { ... }:
      {
        trix = {
          url = "github:aanderse/trix/222013b234cd8db2314f8fca4fff9ac5be5e69f5";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };
    homeManager =
      { pkgs, inputs', ... }:
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
          inputs'.trix.packages.trix
        ];
      };
  };
}
