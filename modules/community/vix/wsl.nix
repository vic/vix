{ inputs, vix, ... }:
{
  flake-file.inputs = {
    nixos-wsl.url = "github:nix-community/nixos-wsl";
  };

  vix.wsl.nixos = {
    imports = [
      inputs.nixos-wsl.nixosModules.default
    ];
    wsl.enable = true;
  };
}
