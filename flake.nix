# env NIX_CONF_DIR="$PWD" nix run
{
  description = "Vic's Nix Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, home-manager, flake-utils }:
    let
      hostName = "oeiuwq";
      intel = "x86_64-darwin";
      sillicon = "aarch64-darwin";
      systems = [ sillicon intel ];
      intelPkgs = builtSystems.packages.${intel};
      buildSystem = (system:
        let
            evalConfig = import "${darwin}/eval-config.nix" {
              inherit (nixpkgs) lib;
              inherit system;
            };

            darwinSystem = { modules, inputs ? { }, ... }@args:
              evalConfig (args // {
                modules = modules ++ [ darwin.darwinModules.flakeOverrides ];
            });

            silliconBackportOverlay = (new: old:
              if system == intel then {}
              else {
                inherit (intelPkgs) 
                # TODO: Remove when PR gets merged. https://github.com/NixOS/nixpkgs/pull/126195
                haskell haskellPackages;
            });

            nixosModules.darwin = {
              imports = [
                ./nix/system.nix
                ./nix/overlays.nix
                # ./nix/hm-link-apps.nix
              ];
              config = { nixpkgs.overlays = [ silliconBackportOverlay ]; };
            };

            nixosConfiguration = darwinSystem {
              modules = [
                home-manager.darwinModules.home-manager
                nixosModules.darwin
                ./nix/vic.nix
              ];
              inputs = { inherit darwin nixpkgs; };
            };

            packages = nixosConfiguration.pkgs // {
              darwinConfigurations.${hostName}.system = defaultPackage;
              sysEnv = packages.buildEnv {
                name = "sysEnv";
                paths = nixosConfiguration.config.environment.systemPackages;
              };
              vicEnv =  packages.buildEnv {
                name = "vicEnv";
                paths = nixosConfiguration.config.home-manager.users.vic.home.packages;
              };
            };

            defaultPackage = nixosConfiguration.system;
            devShell = packages.mkShell { buildInputs = [ packages.vicEnv packages.sysEnv ]; };
            defaultApp = flake-utils.lib.mkApp {
              drv = packages.writeScriptBin "system-switch" "exec ${defaultPackage}/sw/bin/darwin-rebuild switch --flake";
            };
        in
        {
          inherit defaultApp defaultPackage devShell packages;
          nixosConfigurations.${hostName} = nixosConfiguration;
          apps.hello = flake-utils.lib.mkApp { drv = packages.hello; };
        }
      );

      builtSystems = (flake-utils.lib.eachSystem systems buildSystem);
    in
      builtSystems // { inherit hostName systems; };
}
