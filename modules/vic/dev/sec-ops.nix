# sec-ops: sops helper scripts on trusted full homes.
{ yen, at, ... }:
{
  yen.aspects.sec-ops = {
    at = at.all [
      yen.aspects.vic-full
      yen.aspects.vic-secrets
    ];
    homeManager =
      { out, pkgs, ... }:
      let
        own = yen.helpers.own out pkgs;
      in
      {
        home.packages = [
          own.vic-sops-get
          own.vic-sops-rotate
        ];
      };
  };
}
