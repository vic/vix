let
  sources = import ./npins;
  with-inputs = import sources.with-inputs sources (inputs: {
    # uncomment for local checkout on CI
    # flake-file = import ./../../modules;

    helium.inputs.utils.follows = "flake-utils";
    flake-utils.lib.eachDefaultSystem =
      let
        inherit (inputs.nixpkgs) lib;
        eachSystem = lib.genAttrs lib.systems.flakeExposed;
        transpose = inputs.flake-aspects { inherit lib; };
      in
      cb: transpose (eachSystem cb);

    nixpkgs-lib.follows = "nixpkgs";
    jjui.inputs.flake-parts.follows = "fp";
  });

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = { inherit inputs; };
    }).config;
in
with-inputs outputs
