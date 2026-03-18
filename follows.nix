inputs: {
  # den = import ../den;

  nixpkgs-lib.follows = "nixpkgs";

  doom-emacs =
    source:
    source
    // {
      rev = source.revision;
      flake = false;
    };
  helium.inputs.utils.follows = "flake-utils";

  # Shim nix-systems/default
  systems = inputs.nixpkgs.lib.systems.flakeExposed;

  # Shim numtide/flake-utils
  flake-utils.lib =
    let
      inherit (inputs.nixpkgs) lib;
      defaultSystems = lib.systems.flakeExposed;
      transpose = inputs.flake-aspects { inherit lib; };
      eachSystem = systems: cb: transpose (lib.genAttrs systems cb);
      eachDefaultSystem = eachSystem defaultSystems;
    in
    {
      inherit defaultSystems eachSystem eachDefaultSystem;
    };

}
