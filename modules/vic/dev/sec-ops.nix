# sec-ops: sops helper scripts on trusted full homes.
{
  inputs,
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{
  ren.aspects.sec-ops = {
    at = ren.lib.and [
      ren.aspects.vic-full
      ren.aspects.vic-secrets
    ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (vix.perSystem pkgs inputs.self).packages.vic-sops-get
          (vix.perSystem pkgs inputs.self).packages.vic-sops-rotate
        ];
      };
  };
}
