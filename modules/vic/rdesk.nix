# rdesk: remote desktop tools. DISABLED (as in the old tree): no `at`, included nowhere.
{ inputs, ren, ... }:
let
  vix = ren.helpers;
in
{
  ren.aspects.vic-rdesk = {
    unfree = vix.allowUnfree [ "anydesk" ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (vix.perSystem pkgs inputs.self).packages.vic-edge
          pkgs.gsocket
        ];
      };

    homeLinux =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.kdePackages.krdc
          pkgs.xpra
        ];
      };
  };
}
