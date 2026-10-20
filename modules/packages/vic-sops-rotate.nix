# vic-sops-rotate: rotate every vic secret file.
{ ren, ... }:
{
  ren.aspects.vic-sops-rotate = {
    at = ren.kinds.system;
    packages =
      { system, ... }:
      {
        vic-sops-rotate = system.legacyPackages.writeShellApplication {
          name = "vic-sops-rotate";
          text = ''
            # shellcheck disable=SC2011
            ls --zero modules/vic/secrets{.yaml,/*} | xargs -0 -n 1 sops rotate -i
          '';
        };
      };
  };
}
