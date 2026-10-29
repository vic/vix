# vic-sops-rotate: rotate every vic secret file.
{ yen, lib, ... }:
let
  # secrets.yaml and the file of every secret instance
  files = [
    "modules/vic/secrets.yaml"
  ]
  ++ map (s: "modules/vic/secrets/${baseNameOf s.sopsFile}") (
    lib.filter (s: s.sopsFile != null) (lib.attrValues yen.secret)
  );
in
{
  yen.aspects.vic-sops-rotate = {
    at = yen.kinds.system;
    packages =
      { system, ... }:
      {
        vic-sops-rotate = system.legacyPackages.writeShellApplication {
          name = "vic-sops-rotate";
          text = ''
            printf '%s\0' ${lib.escapeShellArgs files} | xargs -0 -n 1 sops rotate -i
          '';
        };
      };
  };
}
