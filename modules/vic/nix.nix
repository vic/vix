{ vic, ... }:
{
  vic.everywhere.includes = [ vic.nix ];
  vic.nix.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.cachix
        pkgs.nix-search-cli
        pkgs.nixd
        pkgs.nixfmt
      ];
    };
}
