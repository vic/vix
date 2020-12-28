{
  description = "OCaml Nix environment";

  inputs = {
    vix.url = "path:../..";
    nixpkgs.follows = "vix/nixpkgs";
  };

  outputs = { self, vix, nixpkgs }:
    let
      inherit (vix.dw) appleArch hostName;
      pkgs = vix.nixosConfigurations.${hostName}.pkgs;
      nodePkgs = pkgs.nodePackages_latest; # import "${nixpkgs}/pkgs/development/node-packages/composition.nix" { inherit pkgs; };
    in {
      devShell.${appleArch} = with pkgs;
        mkShell {
          buildInputs = [ ocaml opam ]; # dune nodePkgs.esy  nodePkgs.ocaml-language-server ];

          shellHook = ''
            echo Welcome to OCaml
          '';
        };
    };
}
