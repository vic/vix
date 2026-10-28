# sec-ops: sops helper scripts on trusted full homes.
{ sven, ... }:
{
  sven.aspects.sec-ops = {
    at = sven.lib.all [
      sven.aspects.vic-full
      sven.aspects.vic-secrets
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
