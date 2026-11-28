# edgevpn: the mudler/edgevpn package (vic-edge wraps it).
{ yen, inputs, ... }:
let
  edgevpnFor =
    pkgs:
    pkgs.buildGoModule {
      name = "edgevpn";
      src = inputs.edgevpn;
      doCheck = false;
      vendorHash = "sha256-8lJKrKEKZhpym27xDWgoLxoNF0S+zMkG4hMDYxo4bIA=";
      meta.mainProgram = "edgevpn";
    };
in
{
  yen.aspects.edgevpn = {
    at = yen.kinds.system;
    flake-file.inputs.edgevpn = {
      url = "github:mudler/edgevpn";
      flake = false;
    };
    packages = { system, ... }: { edgevpn = edgevpnFor system.legacyPackages; };
  };
}
