{ vix-lib, flake-utils, mkDarwinSystem, ... }@args:
let
  hostName = "oeiuwq";
  systems = [ "aarch64-darwin" ];
in flake-utils.lib.eachSystem systems (system:
  mkDarwinSystem {
    inherit hostName system;

    nixosModules = [ (import ./modules args) ];

    # silliconOverlay = silliconPkgs: intelPkgs: {
    #   ntelPkgs) llvmPackages_6;
    # };

    flakeOutputs = { pkgs, ... }@outputs:
      outputs // (with pkgs; {
        packages = pkgs;
        devShell = mkShell { pkgs = [ sysEnv devEnvs.vic ]; };
      });

  })
