{ vix-lib, flake-utils, mkDarwinSystem, ... }@args:
let
  hostName = "oeiuwq";
  systems = [ "aarch64-darwin" ];
in flake-utils.lib.eachSystem systems (system:
  mkDarwinSystem {
    inherit hostName system;

    nixosModules = [{
      config._module.args = { inherit vix-lib; };
      imports = [
        ./modules/default.nix
        ./modules/oeiuwq-aarch64-darwin.nix
        ./modules/vic-at-oeiuwq-aarch64-darwin.nix
      ];
    }];

    # silliconOverlay = silliconPkgs: intelPkgs: {
    #   ntelPkgs) llvmPackages_6;
    # };

    flakeOutputs = { pkgs, ... }@outputs:
      outputs
      // (with pkgs; { packages = pkgs; devShell = mkShell { pkgs = [ sysEnv devEnvs.vic ]; }; });

  })
