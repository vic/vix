# Usage: nix-shell.
# or in .envrc: `use nix`
let
  inherit (outputs) inputs dev;
  outputs = import ./.;
  shell = dev.sh (import inputs.nixpkgs { });
in
shell
