{ vic, inputs, ... }:
{
  vic.everywhere.includes = [ vic.rdesk ];
  vic.rdesk = {

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          inputs.self.packages.${pkgs.stdenvNoCC.hostPlatform.system}.vic-edge
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
