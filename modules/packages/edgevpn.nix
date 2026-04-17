{ inputs, ... }:
let
  flake-file.inputs.edgevpn = {
    url = "github:mudler/edgevpn";
    flake = false;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.edgevpn = pkgs.buildGoModule {
        name = "edgevpn";
        src = inputs.edgevpn;
        doCheck = false;
        vendorHash = "sha256-8lJKrKEKZhpym27xDWgoLxoNF0S+zMkG4hMDYxo4bIA=";
        meta.mainProgram = "edgevpn";
      };
    };
in
{
  inherit flake-file perSystem;
}
