{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
    inputs.home-manager.flakeModules.home-manager
  ];
}
