{ inputs, ... }:
{
  flake-file.inputs = {
    nixos-wsl.url = "github:nix-community/nixos-wsl";
  };

  flake.modules.nixos.wsl = {
    imports = [
      inputs.nixos-wsl.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      inputs.self.modules.nixos.nix-settings
      inputs.self.modules.nixos.unfree
    ];

    wsl.enable = true;
  };
}
