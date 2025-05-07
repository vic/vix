{ inputs, lib, ... }:
let
  flake.nixosConfigurations = {
    annatar = wsl "annatar";
    mordor = linux "mordor";
    nargun = linux "nargun";
    smaug = linux "smaug";
    nienna = linux "nienna";
    tom = linux "tom";
    bombadil = linux "bombadil";
    bill = linux-arm "bill";
  };

  flake.darwinConfigurations = {
    yavanna = darwin-intel "yavanna";
    varda = darwin-arm "varda";
    bert = darwin-arm "bert";
  };

  wsl = mkNixos "x86_64-linux" "wsl";

  linux = mkNixos "x86_64-linux" "nixos";
  linux-arm = mkNixos "aarch64-linux" "nixos";

  darwin-intel = mkDarwin "x86_64-darwin";
  darwin-arm = mkDarwin "aarch64-darwin";

  mkNixos =
    system: cls: name:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        inputs.self.modules.nixos.${cls}
        inputs.self.modules.nixos.${name}
        inputs.self.modules.nixos.${system}
        {
          networking.hostName = lib.mkDefault name;
          nixpkgs.hostPlatform = lib.mkDefault system;
          system.stateVersion = lib.mkDefault "25.05";
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
        inputs.self.modules.darwin.${system}
        {
          networking.hostName = lib.mkDefault name;
          nixpkgs.hostPlatform = lib.mkDefault system;
          system.stateVersion = lib.mkDefault 6;
        }
      ];
    };

in
{
  inherit flake;
}
