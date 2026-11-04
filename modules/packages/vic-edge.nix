# vic-edge: edgevpn wrapper reading the token from sops.
{ yen, ... }:
{
  yen.aspects.vic-edge = {
    at = yen.kinds.system;
    packages =
      {
        system,
        out,
        sops,
        ...
      }:
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
              EDGEVPNTOKEN="''${EDGEVPNTOKEN:-$(< "''${HOME}"/.config/sops-nix/secrets/${
                sops.${yen.secret.edge-token.name}.sopsKey
              })}" \
              ${out.packages.${system.name}.edgevpn}/bin/edgevpn "$@"
          '';
        };
      };
  };
}
