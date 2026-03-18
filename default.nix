let
  sources = import ./npins;
  with-inputs = import sources.with-inputs sources (import ./follows.nix);
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
in
with-inputs outputs
