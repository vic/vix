# nix: nix tooling packages.
{ vicAt, ... }:
{
  ren.aspects.nix-tools = {
    at = vicAt.core;
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
