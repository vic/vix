# Usage: nix-shell.
# or in .envrc: `use nix`
let
  outputs = import ./.;
  inherit (outputs) inputs dev;
  pkgs = import inputs.nixpkgs { };
in
dev.sh pkgs
