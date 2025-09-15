{ inputs, ... }:
let
  perSystem =
    { pkgs, ... }:
    let
      edgevpn = inputs.self.packages.${pkgs.system}.edgevpn;
    in
    {
      packages.vic-edge = pkgs.writeShellApplication {
        name = "vic-edge";
        text = ''
          sudo env \
            ADDRESS="''${ADDRESS:-"192.168.192.192/24"}" \
            EDGEVPNLOGLEVEL="''${EDGEVPNLOGLEVEL:-debug}" \
            EDGEVPNTOKEN="''${EDGEVPNTOKEN:-$(< "''${HOME}"/.config/sops-nix/secrets/edge.token)}" \
            ${edgevpn}/bin/edgevpn "$@"
        '';
      };
    };
in
{
  inherit perSystem;
}
