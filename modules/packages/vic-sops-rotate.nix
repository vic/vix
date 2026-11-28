# vic-sops-rotate: rotate every vic secret file.
{ yen, lib, ... }:
let
  # secrets.yaml and the file of every secret in sops (the fleet `sops` sink)
  filesOf =
    sops:
    [
      "modules/vic/secrets.yaml"
    ]
    ++ map (s: "modules/vic/secrets/${baseNameOf s.sopsFile}") (
      lib.filter (s: s.sopsFile != null) (lib.attrValues sops)
    );
in
{
  yen.aspects.vic-sops-rotate = {
    at = yen.kinds.system;
    packages =
      { system, sops, ... }:
      {
        vic-sops-rotate = system.legacyPackages.writeShellApplication {
          name = "vic-sops-rotate";
          text = ''
            printf '%s\0' ${lib.escapeShellArgs (filesOf sops)} | xargs -0 -n 1 sops rotate -i
          '';
        };
      };
  };
}
