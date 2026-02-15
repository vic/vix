let

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = { inherit inputs; };
    }).config;

  withInputs =
    inputs: outputs:
    outputs (
      inputs
      // {
        # Uncomment to override local checkouts for development
        den = import ./../den/nix;
      }
    );

in
import ./unflake.nix withInputs outputs
