{ flake-utils, mkDarwinSystem, nixpkgs, home-manager, nix-darwin, ...}@inputs:
let
  hostName = "oeiuwq";
  systems = [ "aarch64-darwin" ];
in flake-utils.lib.eachSystem systems (system:
  mkDarwinSystem {
    inherit hostName system;

    nixosModules = [ 
      ({config, pkgs, lib, ...}: {
        config._module.args = { 
          inherit home-manager nixpkgs nix-darwin;
          vix-lib =  import ./lib {inherit lib pkgs config;};
        };
      })
      (import ./modules) 
    ];

    silliconOverlay = silliconPkgs: intelPkgs: {
      inherit (silliconPkgs) pandoc haskell haskellPackages;
    };

    flakeOutputs = { pkgs, ... }@outputs:
      outputs // (with pkgs; {
        packages = pkgs;
        devShell = mkShell { pkgs = [ pkgSets.oeiuwq pkgSets.vic ]; };
      });

  })
