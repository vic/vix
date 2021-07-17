# ####
## > env NIX_CONF_DIR="$PWD" nix run
{
  description = "Vic's Nix Environment";

  inputs = {
    nixpkgs.url =
      "github:nixos/nixpkgs/bb568917b2c8dfc058d534cc4cc0d1e5588b7664";

    #mk-darwin-system.url = "github:vic/mk-darwin-system/main";
    mk-darwin-system.url = "path:../mkDarwinSystem";
    mk-darwin-system.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, mk-darwin-system, nixpkgs, ... }@inputs:
    import ./vix (mk-darwin-system.inputs // {
      vix = self;
      inherit nixpkgs;
      inherit (mk-darwin-system) mkDarwinSystem;
    });
}
