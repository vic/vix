# The fleet as sven queries, outside the flake: the same module flake.nix gives mkFlake.
# Run: nix eval --impure --json --file query.nix check.violations
let
  flake = builtins.getFlake "path:${toString ./.}";
  inputs = flake.inputs // {
    self = flake;
  };
in
(import inputs.sven).lib.eval {
  imports = [ (inputs.import-tree ./modules) ];
  _module.args = {
    inherit inputs;
    inherit (inputs.nixpkgs) lib;
  };
}
