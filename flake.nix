{
  description = "Vic's Nix Environment";

  nixConfig = {
    allow-import-from-derivation = true;

    extra-trusted-public-keys = [
      "vix.cachix.org-1:hP/Lpdsi1dB3AxK9o6coWh+xHzvAc4ztdDYuG7lC6dI="
      "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
    ];
    extra-substituters = [
      "https://vix.cachix.org"
      "https://nvf.cachix.org"
    ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable&shallow=1";

    systems.url = "github:nix-systems/default?ref=main&shallow=1";

    blueprint.url = "github:numtide/blueprint?shallow=1";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin?ref=master&shallow=1";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl?ref=main&shallow=1";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager?ref=master&shallow=1";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:nix-community/nixos-vscode-server?ref=master&shallow=1";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    cli-leader.url = "github:dhamidi/leader?ref=14373a2&shallow=1";
    cli-leader.flake = false;

    nox.url = "github:madsbv/nix-options-search?ref=main&shallow=1";
    nox.inputs.nixpkgs.follows = "nixpkgs";

    devshell.url = "github:numtide/devshell?ref=main&shallow=1";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix?ref=master&shallow=1";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database?ref=main&shallow=1";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    use_devshell_toml.url = "github:vic/use_devshell_toml";
    use_devshell_toml.inputs.nixpkgs.follows = "nixpkgs";
    use_devshell_toml.inputs.treefmt-nix.follows = "treefmt-nix";

    SPC.url = "github:vic/SPC";
    SPC.inputs.nixpkgs.follows = "nixpkgs";

    doom-emacs.url = "github:doomemacs/doomemacs";
    doom-emacs.flake = false;

    nvf.url = "github:notashelf/nvf";
  };

  outputs = inputs: inputs.blueprint { inherit inputs; };
}
