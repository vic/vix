{ inputs, ... }:
{
  flake.modules.nixos.nixos.imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.self.modules.nixos.bootable
    inputs.self.modules.nixos.nix-settings
    inputs.self.modules.nixos.unfree
  ];
}
