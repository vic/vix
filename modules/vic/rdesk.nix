# rdesk: remote desktop tools. DISABLED (as in the old tree): `at` is empty, active nowhere.
{ yen, ... }:
{
  yen.aspects.vic-rdesk = {
    at = [ ];
    unfree = yen.helpers.allowUnfree [ "anydesk" ];

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
