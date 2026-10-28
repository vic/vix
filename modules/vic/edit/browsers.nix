# browsers: browsers and the fish helpers that open nixos search pages.
{ sven, inputs, ... }:
{
  sven.aspects.vic-browsers = {
    at = sven.lib.all [
      sven.aspects.vic-full
      sven.aspects.vic-gui
    ];
    flake-file.inputs = {
      helium = {
        url = "github:vikingnope/helium-browser-nix-flake";
        inputs = {
          nixpkgs.follows = "nixpkgs";
          nixpkgs-darwin.follows = "nixpkgs-darwin";
          utils.follows = "flake-utils";
        };
      };
      nixpkgs-darwin.follows = "nixpkgs";
      flake-utils.url = "github:numtide/flake-utils";
    };
    fish-functions = {
      nixos-opt.description = "Open a browser on search.nixos.org for options";
      nixos-opt.body = ''open "https://search.nixos.org/options?sort=relevance&query=$argv"'';
      nixos-pkg.description = "Open a browser on search.nixos.org for packages";
      nixos-pkg.body = ''open "https://search.nixos.org/packages?sort=relevance&query=$argv"'';
      repology-nixpkgs.description = "Open a browser on search for nixpkgs on repology.org";
      repology-nixpkgs.body = ''open "https://repology.org/projects/?inrepo=nix_unstable&search=$argv"'';
    };
    homeManager =
      { lib, pkgs, ... }:
      {
        # chromium has no darwin build; keep only browsers the host platform supports
        home.packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) [
          pkgs.chromium
          pkgs.librewolf
          pkgs.qutebrowser
          (sven.helpers.perSystem pkgs inputs.helium).packages.default
        ];
      };
  };
}
