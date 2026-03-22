{ vic, ... }:
{
  flake-file.inputs.trix.url = "github:aanderse/trix";

  vic.everywhere.includes = [ vic.nix ];
  vic.nix.homeManager =
    { pkgs, inputs', ... }:
    {
      home.packages = [
        pkgs.cachix
        pkgs.nix-search-cli
        pkgs.nixd
        pkgs.nixfmt
        pkgs.nix-run
        inputs'.trix.packages.trix
      ];
    };
}
