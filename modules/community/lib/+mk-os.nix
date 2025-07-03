{ inputs, lib, ... }:
let
  flake.lib.mk-os = {
    inherit mkNixos mkDarwin;
    inherit wsl linux linux-arm;
    inherit darwin darwin-intel;
  };

  wsl = mkNixos "x86_64-linux" "wsl";

  linux = mkNixos "x86_64-linux" "nixos";
  linux-arm = mkNixos "aarch64-linux" "nixos";

  darwin-intel = mkDarwin "x86_64-darwin";
  darwin = mkDarwin "aarch64-darwin";

  mkNixos =
    system: cls: name:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        inputs.self.modules.nixos.${cls}
        inputs.self.modules.nixos.${name}
        {
          networking.hostName = lib.mkDefault name;
          nixpkgs.hostPlatform = lib.mkDefault system;
          system.stateVersion = "25.05";
        }
      ];
    };

  mkDarwin =
    system: name:
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        inputs.self.modules.darwin.darwin
        inputs.self.modules.darwin.${name}
        {
          networking.hostName = lib.mkDefault name;
          nixpkgs.hostPlatform = lib.mkDefault system;
          system.stateVersion = 6;
        }
      ];
    };
in
{
  inherit flake;
}
