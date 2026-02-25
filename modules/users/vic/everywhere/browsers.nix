{ inputs, lib, ... }:
{

  flake-file.inputs.helium = {
    url = "github:schembriaiden/helium-browser-nix-flake";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.utils.follows = "flake-utils";
  };

  vic.everywhere.user =
    { pkgs, system', ... }:
    {
      packages = [ (system' inputs.helium).packages.helium ];
    };

}
