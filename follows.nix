inputs: {

  nixpkgs-lib.follows = "nixpkgs";
  helium.inputs.utils.follows = "flake-utils";

  den =
    if builtins.pathExists ../den.sini then
      {
        outPath = ../den.sini;
      }
    else
      { };

  flake-aspects =
    if builtins.pathExists ../flake-aspects then
      {
        outPath = ../flake-aspects;
      }
    else
      { };

  doom-emacs =
    source:
    source
    // {
      rev = source.revision;
      flake = false;
    };

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
