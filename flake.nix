{
  # env TERM=xterm darwin-rebuild switch --flake '.#oeiuwq'
  description = "Vic's Nix Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-20.09-darwin";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, home-manager }:
    let
      configuration = { pkgs, ... }: {
        nix.package = pkgs.nixFlakes;
        nix.extraOptions = ''
                    build-users-group = nixbld
                    experimental-features = nix-command flakes
                  '';
        services.nix-daemon.enable = true;
        environment.systemPackages = with pkgs; [ htop vim pkgs.nixFlakes pkgs.home-manager ];
        system.stateVersion = 4;
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.vic = {
            home.packages = with pkgs; [
              bat
              browsh
              coursier
              dbmate
              direnv
              emacsMacport
              exa
              fd
              fish
              fzf
              gettext
              git-lfs
              kubernetes-helm
              jq
              mill
              niv
              nixfmt
              nodejs
              nox
              ripgrep-all
              tig
              victor-mono
              iterm2
            ];
          };
        };
      };
    in {
      darwinConfigurations.oeiuwq = darwin.lib.darwinSystem {
        modules = [ configuration home-manager.darwinModules.home-manager ];
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
