{
  # env TERM=xterm darwin-rebuild switch --flake '.#oeiuwq'
  description = "Vic's Nix Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, home-manager }:
    {
      darwinConfigurations.oeiuwq = darwin.lib.darwinSystem {
        modules = [
          ./nix/system.nix
          ./nix/vic.nix
          ./nix/overlays.nix
          home-manager.darwinModules.home-manager
        ];
      };

      darwinPackages = self.darwinConfigurations.oeiuwq.pkgs;

      # Build darwin flake using:
      # $ darwin-rebuild build --flake '.#oeiuwq' --override-input darwin .
      # $ nix build '.#darwinConfigurations.oeiuwq.system'
      defaultPackage.${self.darwinPackages.system} =
        self.darwinConfigurations.oeiuwq.system;

      defShell =
        self.darwinPackages.mkShell { inputsFrom = [ self.defaultPackage ]; };
    };
}
