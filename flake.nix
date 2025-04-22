{
  description = "Vic's Nix Environment";

  nixConfig = {
    allow-import-from-derivation = true;

    extra-trusted-public-keys = [
      "vix.cachix.org-1:hP/Lpdsi1dB3AxK9o6coWh+xHzvAc4ztdDYuG7lC6dI="
    ];
    extra-substituters = [ "https://vix.cachix.org" ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";

    systems.url = "github:nix-systems/default";

    # not used here but followed by other deps to get a flat dep tree
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
    blueprint.inputs.systems.follows = "systems";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";
    vscode-server.inputs.flake-utils.follows = "flake-utils";

    cli-leader.url = "github:dhamidi/leader?ref=14373a2";
    cli-leader.flake = false;

    nox.url = "github:madsbv/nix-options-search";
    nox.inputs.nixpkgs.follows = "nixpkgs";
    nox.inputs.flake-utils.follows = "flake-utils";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    use_devshell_toml.url = "github:vic/use_devshell_toml";
    use_devshell_toml.inputs.nixpkgs.follows = "nixpkgs";
    use_devshell_toml.inputs.treefmt-nix.follows = "treefmt-nix";

    SPC.url = "github:vic/SPC";
    SPC.inputs.nixpkgs.follows = "nixpkgs";
    SPC.inputs.blueprint.follows = "blueprint";
    SPC.inputs.treefmt-nix.follows = "treefmt-nix";

    doom-emacs.url = "github:doomemacs/doomemacs";
    doom-emacs.flake = false;

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-versions.url = "github:vic/nix-versions";
    nix-versions.inputs.nixpkgs.follows = "nixpkgs";
    nix-versions.inputs.flake-parts.follows = "flake-parts";
    nix-versions.inputs.systems.follows = "systems";
    nix-versions.inputs.treefmt-nix.follows = "treefmt-nix";

    rust-overlay.url = "github:oxalica/rust-overlay";
    crane.url = "github:ipetkov/crane";

    nci.url = "github:yusdacra/nix-cargo-integration";
    nci.inputs.nixpkgs.follows = "nixpkgs";
    nci.inputs.parts.follows = "flake-parts";
    nci.inputs.crane.follows = "crane";
    nci.inputs.treefmt.follows = "treefmt-nix";
    nci.inputs.rust-overlay.follows = "rust-overlay";

    nix-inspect.url = "github:bluskript/nix-inspect";
    nix-inspect.inputs.nixpkgs.follows = "nixpkgs";
    nix-inspect.inputs.parts.follows = "flake-parts";
    nix-inspect.inputs.nci.follows = "nci";

    radicle.url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5.git";
    radicle.inputs.nixpkgs.follows = "nixpkgs";
    radicle.inputs.flake-utils.follows = "flake-utils";
    radicle.inputs.crane.follows = "crane";
    radicle.inputs.rust-overlay.follows = "rust-overlay";

    devicon-lookup.url = "github:coreyja/devicon-lookup";
    devicon-lookup.flake = false;

    jj-fzf.url = "github:tim-janik/jj-fzf";
    jj-fzf.flake = false;

    lazyjj.url = "github:Cretezy/lazyjj";
    lazyjj.flake = false;

    jjui.url = "github:idursun/jjui";

    ntv.url = "github:vic/ntv?dir=nix/flakeModules";
    ntv.inputs.nixpkgs.follows = "nixpkgs";
    ntv.inputs.systems.follows = "systems";
    ntv.inputs.devshell.follows = "devshell";
    ntv.inputs.flake-parts.follows = "flake-parts";

    versioned.url = "https://nix-versions.alwaysdata.net/flake.zip/input-leap";
    versioned.inputs.nixpkgs.follows = "nixpkgs";
    versioned.inputs.ntv.follows = "ntv";

  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
    };
}
