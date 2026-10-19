# rdesk: remote desktop tools. DISABLED (as in the old tree): no `at`, included nowhere.
{ allowUnfree, ... }:
{
  ren.aspects.vic-rdesk = {
    unfree = allowUnfree [ "anydesk" ];

    homeManager =
      { pkgs, self', ... }:
      {
        home.packages = [
          self'.packages.vic-edge
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
