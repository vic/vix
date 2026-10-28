# vic-edge: edgevpn wrapper reading the token from sops.
{ sven, ... }:
{
  sven.aspects.vic-edge = {
    at = sven.kinds.system;
    packages =
      { system, out, ... }:
      let
        pkgs = system.legacyPackages;
      in
      {
        vic-edge = pkgs.writeShellApplication {
          name = "vic-edge";
          text = ''
            sudo env \
              ADDRESS="''${ADDRESS:-"192.168.192.192/24"}" \
              EDGEVPNLOGLEVEL="''${EDGEVPNLOGLEVEL:-debug}" \
              EDGEVPNTOKEN="''${EDGEVPNTOKEN:-$(< "''${HOME}"/.config/sops-nix/secrets/${sven.secret.edge-token.sopsKey})}" \
              ${out.packages.${system.name}.edgevpn}/bin/edgevpn "$@"
          '';
        };
      };
  };
}
