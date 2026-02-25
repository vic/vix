{ inputs, ... }:
{
  imports = [
    inputs.den.flakeModule
    inputs.flake-file.flakeModules.npins
  ];

  flake-file.inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

    den.url = "github:vic/den";
    import-tree.url = "github:vic/import-tree";
    flake-file.url = "github:vic/flake-file";
    flake-aspects.url = "github:vic/flake-aspects";
  };
}
