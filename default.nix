let

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = { inherit inputs; };
    }).config;

  sources = import ./deps.nix;
  inputs = {
    # Local checkouts — direct imports (no flake.nix at these paths)
    den         = import ./../den/nix;
    flake-file  = import ./../flake-file/modules;
    import-tree = import ./../import-tree;
    with-inputs = import ./../with-inputs;
  };

in
inputs.with-inputs sources inputs outputs
