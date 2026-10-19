# sec-ops: sops helper scripts on trusted full homes.
{ ren, vicAt, ... }:
{
  ren.aspects.sec-ops = {
    at = ren.lib.and [
      vicAt.full
      vicAt.secrets
    ];
    homeManager =
      { self', ... }:
      {
        home.packages = [
          self'.packages.vic-sops-get
          self'.packages.vic-sops-rotate
        ];
      };
  };
}
