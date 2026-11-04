# The fleet as yen queries, outside the flake: the same module flake.nix gives mkFlake.
# Run: nix eval --impure --file query.nix errors
let
  flake = builtins.getFlake "path:${toString ./.}";
  inputs = flake.inputs // {
    self = flake;
  };
in
(import inputs.yen).lib.eval {
  imports = [ (inputs.import-tree ./modules) ];
  inherit inputs;
  inherit (inputs.nixpkgs) lib;
  yen.sinks = {
    inputs = { };
    lib = { };
  };
}
