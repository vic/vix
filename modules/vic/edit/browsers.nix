{ ... }:
{
  flake-file.inputs.helium.url = "github:vikingnope/helium-browser-nix-flake";

  vic.browsers = {
    hm =
      { pkgs, inputs', ... }:
      {
        home.packages = [
          pkgs.chromium
          pkgs.librewolf
          pkgs.qutebrowser
          inputs'.helium.packages.default
        ];

        programs.fish.functions = {
          nixos-opt.description = "Open a browser on search.nixos.org for options";
          nixos-opt.body = ''open "https://search.nixos.org/options?sort=relevance&query=$argv"'';
          nixos-pkg.description = "Open a browser on search.nixos.org for packages";
          nixos-pkg.body = ''open "https://search.nixos.org/packages?sort=relevance&query=$argv"'';
          repology-nixpkgs.description = "Open a browser on search for nixpkgs on repology.org";
          repology-nixpkgs.body = ''open "https://repology.org/projects/?inrepo=nix_unstable&search=$argv"'';
        };
      };
  };
}
