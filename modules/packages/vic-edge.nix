# vic-edge: edgevpn wrapper reading the token from sops.
{
  ren,
  pkgsFor,
  edgevpnFor,
  ...
}:
{
  ren.aspects.vic-edge = {
    at = ren.kinds.system;
    packages =
      { system, ... }:
      let
        pkgs = pkgsFor system;
      in
      {
        vic-edge = pkgs.writeShellApplication {
          name = "vic-edge";
          text = ''
            sudo env \
              ADDRESS="''${ADDRESS:-"192.168.192.192/24"}" \
              EDGEVPNLOGLEVEL="''${EDGEVPNLOGLEVEL:-debug}" \
              EDGEVPNTOKEN="''${EDGEVPNTOKEN:-$(< "''${HOME}"/.config/sops-nix/secrets/edge.token)}" \
              ${edgevpnFor pkgs}/bin/edgevpn "$@"
          '';
        };
      };
  };
}
