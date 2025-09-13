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
        vendorHash = "sha256-/YAE34MmGsluncabzTcyIGYQUFDPUKidol7hZP2uR20=";
        meta.mainProgram = "edgevpn";
      };
    };
in
{
  inherit flake-file perSystem;
}
