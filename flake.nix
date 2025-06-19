{
  description = "Vic's Nix Environment";

  outputs = inputs: import ./. inputs;

  nixConfig = {
    allow-import-from-derivation = true;
    extra-trusted-public-keys = [
      "vix.cachix.org-1:hP/Lpdsi1dB3AxK9o6coWh+xHzvAc4ztdDYuG7lC6dI="
    ];
    extra-substituters = [ "https://vix.cachix.org" ];
  };

  inputs = {

    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";
    doom-emacs.flake = false;
    doom-emacs.url = "github:doomemacs/doomemacs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    import-tree.url = "github:vic/import-tree";
    jjui.inputs.flake-parts.follows = "flake-parts";
    jjui.inputs.nixpkgs.follows = "nixpkgs";
    jjui.inputs.systems.follows = "systems";
    jjui.url = "github:idursun/jjui";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    ntv.inputs.devshell.follows = "devshell";
    ntv.inputs.flake-parts.follows = "flake-parts";
    ntv.inputs.nixpkgs.follows = "nixpkgs";
    ntv.inputs.systems.follows = "systems";
    ntv.url = "github:vic/ntv?dir=nix/flakeModules";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    SPC.inputs.nixpkgs.follows = "nixpkgs";
    SPC.inputs.treefmt-nix.follows = "treefmt-nix";
    SPC.url = "github:vic/SPC";
    systems.url = "github:nix-systems/default";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    #versioned.inputs.nixpkgs.follows = "nixpkgs";
    #versioned.inputs.ntv.follows = "ntv";
    #versioned.url = "https://nix-versions.alwaysdata.net/flake.zip/lazamar:input-leap";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

  };
}
