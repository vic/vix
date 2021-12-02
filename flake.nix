# ####
## > env NIX_CONF_DIR="$PWD" nix run
{
  description = "Vic's Nix Environment";

  inputs = {
    nixpkgs.url =
      "github:nixos/nixpkgs/21.11"; # change tag or commit of nixpkgs for your system

    #mk-darwin-system.url = "github:vic/mk-darwin-system/main"; # change main to a tag o git revision
    mk-darwin-system.url = "path:/hk/mkDarwinSystem"; # development mode
    mk-darwin-system.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, mk-darwin-system, ... }:
    (let
      darwinFlakeOutput = mk-darwin-system.outputs.mkDarwinSystem.m1 {

        nixosModules = [
          ({ config, pkgs, lib, ... }: {
            config._module.args = let
              vix = self;
              inherit (mk-darwin-system.inputs) home-manager nix-darwin;
            in {
              inherit home-manager nixpkgs nix-darwin vix;
              vix-lib = import ./vix/lib { inherit lib pkgs config vix; };
            };
          })

          (import ./vix/modules/oeiuwq/intel-overlay.nix nixpkgs.legacyPackages.x86_64-darwin)

          ./vix/modules
        ];
      };
    in darwinFlakeOutput // {
      nixosConfigurations."oeiuwq" =
        darwinFlakeOutput.nixosConfiguration.aarch64-darwin;
    });
}
