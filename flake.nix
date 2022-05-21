# ####
## > env NIX_CONF_DIR="$PWD" nix run
{
  description = "Vic's Nix Environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/91c498f0f2505d6f1af5a0151312d282deba201b";
    # change tag or commit of nixpkgs for your system
    #mk-darwin-system.url = "github:vic/mk-darwin-system/main"; # change main to a tag o git revision
    mk-darwin-system.url = "path:/hk/mkDarwinSystem";

    # development mode
    mk-darwin-system.inputs.nixpkgs.follows = "nixpkgs";
    alejandra.url = "github:kamadorueda/alejandra";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    SPC.url = "github:vic/SPC";
    SPC.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    mk-darwin-system,
    ...
  }: let
    darwinFlakeOutput = mk-darwin-system.mkDarwinSystem.m1 {
      flakePath = "/hk/vix";
      modules = [
        ({
          pkgs,
          lib,
          ...
        }: {
          config._module.args = {
            vix =
              self
              // {
                lib = import ./vix/lib {
                  vix = self;
                  inherit pkgs lib;
                };
              };
          };
        })
        ./vix/modules
      ];
    };
  in
    darwinFlakeOutput
    // {
      darwinConfigurations."yavanna" =
        darwinFlakeOutput.darwinConfiguration.aarch64-darwin;
    };
}
