# edgevpn: the mudler/edgevpn package (module arg edgevpnFor builds it for a pkgs).
{
  ren,
  inputs,
  pkgsFor,
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
  _module.args = { inherit edgevpnFor; };

  ren.aspects.edgevpn = {
    at = ren.kinds.system;
    packages = { system, ... }: { edgevpn = edgevpnFor (pkgsFor system); };
  };
}
