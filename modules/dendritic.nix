{ inputs, ... }:
{
  imports = [
    (inputs.den.flakeModule or { })
    (inputs.flake-file.flakeModules.npins or { })
  ];

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    den.url = "github:vic/den";
    import-tree.url = "github:vic/import-tree";
    flake-file.url = "github:vic/flake-file";
    flake-aspects.url = "github:vic/flake-aspects";
    with-inputs.url = "github:vic/with-inputs";

    # Dont need these
    nixpkgs-lib.follows = "";
    flake-parts.follows = "";
    flake-utils.follows = "";
    flake-compat.follows = "";
    systems.follows = "";

    # needed by some deps like jjui and others
    fp.url = "github:hercules-ci/flake-parts";
  };

}
