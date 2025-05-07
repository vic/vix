{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
    inputs.flake-parts.flakeModules.modules
    inputs.home-manager.flakeModules.home-manager
    inputs.treefmt-nix.flakeModule
  ];
}
