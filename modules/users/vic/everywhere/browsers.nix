{ inputs, lib, ... }:
{

  flake-file.inputs.helium = {
    url = "github:schembriaiden/helium-browser-nix-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  vic.everywhere.user =
    { pkgs, system', ... }:
    {
      packages = [ (system' inputs.helium).packages.helium ];
    };

}
