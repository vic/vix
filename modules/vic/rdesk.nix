# rdesk: remote desktop tools. DISABLED (as in the old tree): `at` is empty, active nowhere.
{ sven, ... }:
{
  sven.aspects.vic-rdesk = {
    at = [ ];
    unfree = sven.helpers.allowUnfree [ "anydesk" ];

    homeManager =
      { out, pkgs, ... }:
      {
        home.packages = [
          out.packages.${pkgs.stdenv.hostPlatform.system}.vic-edge
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
