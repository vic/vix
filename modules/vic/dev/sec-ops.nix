# sec-ops: sops helper scripts on trusted full homes.
{ yen, ... }:
{
  yen.aspects.sec-ops = {
    at = yen.lib.all [
      yen.aspects.vic-full
      yen.aspects.vic-secrets
    ];
    homeManager =
      { out, pkgs, ... }:
      let
        own = out.packages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        home.packages = [
          own.vic-sops-get
          own.vic-sops-rotate
        ];
      };
  };
}
