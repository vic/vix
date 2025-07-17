{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
    inputs.home-manager.flakeModules.home-manager
  ];

  flake-file.inputs = {
    devshell.url = "github:numtide/devshell";
    home-manager.url = "github:nix-community/home-manager";
  };
}
