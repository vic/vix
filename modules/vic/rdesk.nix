{ inputs, ... }:
{
  vic.rdesk.homeManager =
    { pkgs, lib, ... }:
    {
      home.packages =
        lib.optionals pkgs.stdenvNoCC.isLinux [
          pkgs.kdePackages.krdc
          pkgs.xpra
        ]
        ++ [
          inputs.self.packages.${pkgs.stdenvNoCC.hostPlatform.system}.vic-edge
          pkgs.gsocket
        ];
    };
}
