{ inputs, ... }:
let
  flake.modules.nixos.vic.imports = [
    inputs.self.modules.nixos.rdesk
  ];

  remotes =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.kdePackages.krdc
        pkgs.gsocket
      ];
    };

  flake.modules.homeManager.vic.imports = [
    inputs.self.modules.homeManager.rdesk
    remotes
  ];
in
{
  inherit flake;
}
