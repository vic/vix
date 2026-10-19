# browsers: browsers and the fish helpers that open nixos search pages.
{ ren, vicAt, ... }:
{
  ren.aspects.vic-browsers = {
    at = ren.lib.and [
      vicAt.full
      vicAt.gui
    ];
    flake-inputs =
      { ... }:
      {
        helium = {
          url = "github:vikingnope/helium-browser-nix-flake/0df2692a56b16a6101e0ad6ed0133c59241b9591";
          inputs = {
            nixpkgs.follows = "nixpkgs";
            nixpkgs-darwin.follows = "nixpkgs-darwin";
            utils.follows = "flake-utils";
          };
        };
        nixpkgs-darwin.url = "github:NixOS/nixpkgs/240fddad86d7a0520319f21d8be1b43db426b18d";
        flake-utils.url = "github:numtide/flake-utils/04c1b180862888302ddfb2e3ad9eaa63afc60cf8";
      };
    fish-functions = { ... }: {
      nixos-opt.description = "Open a browser on search.nixos.org for options";
      nixos-opt.body = ''open "https://search.nixos.org/options?sort=relevance&query=$argv"'';
      nixos-pkg.description = "Open a browser on search.nixos.org for packages";
      nixos-pkg.body = ''open "https://search.nixos.org/packages?sort=relevance&query=$argv"'';
      repology-nixpkgs.description = "Open a browser on search for nixpkgs on repology.org";
      repology-nixpkgs.body = ''open "https://repology.org/projects/?inrepo=nix_unstable&search=$argv"'';
    };
    homeManager =
      { pkgs, inputs', ... }:
      {
        home.packages = [
          pkgs.chromium
          pkgs.librewolf
          pkgs.qutebrowser
          inputs'.helium.packages.default
        ];
      };
  };
}
