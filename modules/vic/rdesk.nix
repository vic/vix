{ inputs, ... }:
let
  flake.modules.nixos.vic.imports = [
    inputs.self.modules.nixos.rdesk
  ];

  flake.modules.homeManager.vic.imports = [ inputs.self.modules.homeManager.rdesk ];
in
{
  inherit flake;
}
