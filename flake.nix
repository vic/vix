# ####
## > env NIX_CONF_DIR="$PWD" nix run
{
  description = "Vic's Nix Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    #mk-darwin-system.url = "github:vic/mk-darwin-system/main";
    mk-darwin-system.url = "path:../mkDarwinSystem";
    mk-darwin-system.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { mk-darwin-system, nixpkgs, ... }@inputs:
    import ./default.nix (mk-darwin-system.inputs // {
      inherit nixpkgs;
      inherit (mk-darwin-system) mkDarwinSystem;
      vix-lib = import ./lib inputs;
    });
}
