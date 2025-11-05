{ inputs, ... }:
let
  flake.modules.nixos.annatar.imports = with inputs.self.modules.nixos; [
    vic
    { wsl.defaultUser = "vic"; }
  ];
in
{
  inherit flake;
}
