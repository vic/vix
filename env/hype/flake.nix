{
  description = "hype projects";

  inputs.vix.url = "github:vic/vix";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, vix, nixpkgs, flake-utils }:
    builtins.trace vix
    flake-utils.lib.eachDefaultSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          devShell = import ./shell.nix { inherit pkgs; };
        }
      );


}
