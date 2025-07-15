# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Vic's Nix Environment";
  inputs = {
    SPC = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
        treefmt-nix = {
          follows = "treefmt-nix";
        };
      };
      url = "github:vic/SPC";
    };
    allfollow = {
      url = "github:spikespaz/allfollow";
    };
    devshell = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:numtide/devshell";
    };
    doom-emacs = {
      flake = false;
      url = "github:doomemacs/doomemacs";
    };
    flake-file = {
      url = "github:vic/flake-file";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    home-manager = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/home-manager";
    };
    import-tree = {
      url = "github:vic/import-tree";
    };
    jjui = {
      url = "github:vic/jjui/exec";
    };
    nix-darwin = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:LnL7/nix-darwin";
    };
    nix-index-database = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/nix-index-database";
    };
    nixos-wsl = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/nixos-wsl";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    rust-overlay = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:oxalica/rust-overlay";
    };
    sops-nix = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:Mic92/sops-nix";
    };
    systems = {
      url = "github:nix-systems/default";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
    };
    vscode-server = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/nixos-vscode-server";
    };
  };
  nixConfig = {
    allow-import-from-derivation = true;
    extra-substituters = [ "https://vix.cachix.org" ];
    extra-trusted-public-keys = [ "vix.cachix.org-1:hP/Lpdsi1dB3AxK9o6coWh+xHzvAc4ztdDYuG7lC6dI=" ];
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
