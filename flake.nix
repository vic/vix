#####
## > env NIX_CONF_DIR="$PWD" nix run
{
  description = "Vic's Nix Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    mk-darwin-system.url = "github:vic/mk-darwin-system/main";
    mk-darwin-system.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { mk-darwin-system, nixpkgs, ... }@inputs:
    import ./default.nix (mk-darwin-system.inputs // {
      inherit nixpkgs;
      inherit (mk-darwin-system) mkDarwinSystem;
      vix-lib = import ./lib inputs;
    });
}
