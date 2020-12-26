{
  # env TERM=xterm darwin-rebuild switch --flake '.#oeiuwq'
  description = "Vic's Nix Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, home-manager, flake-utils }:
  {

    nixosConfigurations.ashura = darwin.lib.darwinSystem {
      modules = [
        home-manager.darwinModules.home-manager
        self.nixosModules.darwin
        ./nix/vic.nix
      ];
    };

    nixosModules.darwin = {
      imports = [
        ./nix/system.nix
        ./nix/overlays.nix
        # ./nix/hm-link-apps.nix
      ];
    };

    packages.x86_64-darwin =
      self.nixosConfigurations.ashura.pkgs;

    defaultPackage.x86_64-darwin =
      self.nixosConfigurations.ashura.system;

    defaultApp.x86_64-darwin = {
      type = "app";
      program =
        let
          program =
            with self.nixosConfigurations.ashura.pkgs;
            writeScriptBin "activate" ''
              sudo ${self.nixosConfigurations.ashura.system}/activate
            '';
        in "${program}/bin/activate";
    };

  };

}
