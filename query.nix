# Direct Yen fleet query entry point (no import-tree needed):
#   nix eval --impure --json --file query.nix errors
#   nix eval --impure --json --file query.nix check.ok
let
  flake = builtins.getFlake "path:${toString ./.}";
  inputs = flake.inputs // {
    self = flake;
  };
  yen = import inputs.yen;
in
yen.eval {
  args = {
    inherit inputs;
    inherit (inputs.nixpkgs) lib;
  };
  modules = ./modules;
}
