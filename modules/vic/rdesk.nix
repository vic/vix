{ inputs, ... }:
let
  flake.modules.nixos.vic.imports = [
    inputs.self.modules.nixos.rdesk
  ];

  linux =
    { pkgs, lib, ... }:
    lib.mkIf pkgs.stdenvNoCC.isLinux {
      home.packages = [
        pkgs.kdePackages.krdc
        pkgs.xpra
      ];
    };

  any =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.self.packages.${pkgs.system}.vic-edge
        pkgs.gsocket
      ];
    };

  flake.modules.homeManager.vic.imports = [
    inputs.self.modules.homeManager.rdesk
    linux
    any
  ];
in
{
  inherit flake;
}
