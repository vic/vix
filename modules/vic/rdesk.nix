{
  vic,
  den,
  ...
}:
{
  vic.everywhere.includes = [ vic.rdesk ];
  vic.rdesk = {

    includes = [
      (den.provides.unfree [ "anydesk" ])
    ];

    homeManager =
      { pkgs, self', ... }:
      {
        home.packages = [
          self'.packages.vic-edge
          pkgs.gsocket
        ];
      };

    hmLinux =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.kdePackages.krdc
          pkgs.xpra
        ];
      };
  };
}
