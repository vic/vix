{ inputs, ... }:
{
  imports = [
    (inputs.den.flakeModule or { })
    (inputs.flake-file.flakeModules.npins or { })
  ];

  flake-file.inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    nixpkgs-lib.follows = "nixpkgs";

    den.url = "github:vic/den";
    import-tree.url = "github:vic/import-tree";
    flake-file.url = "github:vic/flake-file";
    flake-aspects.url = "github:vic/flake-aspects";
  };
}
