# edgevpn: the mudler/edgevpn package (vic-edge wraps it).
{
  ren,
  inputs,
  ...
}:
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

  ren.aspects.edgevpn = {
    at = ren.kinds.system;
    flake-inputs =
      { ... }:
      {
        edgevpn = {
          url = "github:mudler/edgevpn/fa89190c1c0c0ab20a82a7de5159e08effbd359a";
          flake = false;
        };
      };
    packages = { system, ... }: { edgevpn = edgevpnFor system.legacyPackages; };
  };
}
