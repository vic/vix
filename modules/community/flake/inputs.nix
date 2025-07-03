{ inputs, ... }:
{

  imports = [ inputs.flake-file.flakeModules.dendritic ];

  flake-file = {
    description = "Vic's Nix Environment";

    nixConfig = {
      allow-import-from-derivation = true;
      extra-trusted-public-keys = [
        "vix.cachix.org-1:hP/Lpdsi1dB3AxK9o6coWh+xHzvAc4ztdDYuG7lC6dI="
      ];
      extra-substituters = [ "https://vix.cachix.org" ];
    };

    inputs = {
      flake-file.url = "github:vic/flake-file";
      devshell.follows.nixpkgs= "nixpkgs";
      devshell.url = "github:numtide/devshell";
      doom-emacs.flake = false;
      doom-emacs.url = "github:doomemacs/doomemacs";
      home-manager.follows.nixpkgs = "nixpkgs";
      home-manager.url = "github:nix-community/home-manager";
      nix-darwin.follows.nixpkgs = "nixpkgs";
      nix-darwin.url = "github:LnL7/nix-darwin";
      nix-index-database.follows.nixpkgs = "nixpkgs";
      nix-index-database.url = "github:nix-community/nix-index-database";
      ntv.follows.devshell= "devshell";
      ntv.follows.flake-parts= "flake-parts";
      ntv.follows.nixpkgs= "nixpkgs";
      ntv.follows.systems= "systems";
      ntv.url = "github:vic/ntv?dir=nix/flakeModules";
      sops-nix.follows.nixpkgs= "nixpkgs";
      sops-nix.url = "github:Mic92/sops-nix";
      SPC.follows.nixpkgs = "nixpkgs";
      SPC.follows.treefmt-nix = "treefmt-nix";
      SPC.url = "github:vic/SPC";
      #versioned.inputs.nixpkgs.follows = "nixpkgs";
      #versioned.inputs.ntv.follows = "ntv";
      #versioned.url = "https://nix-versions.alwaysdata.net/flake.zip/lazamar:input-leap";
      vscode-server.follows.nixpkgs = "nixpkgs";
      vscode-server.url = "github:nix-community/nixos-vscode-server";
      nixos-wsl.url = "github:nix-community/nixos-wsl";
      nixos-wsl.follows.nixpkgs = "nixpkgs";
    };
  };

}
