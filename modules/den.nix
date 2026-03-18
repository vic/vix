{
  inputs,
  lib,
  den,
  ...
}:
{
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "vix" true)
    (inputs.den.namespace "vic" true)
  ];
  options.flake.darwinConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };
  config._module.args.__findFile = den.lib.__findFile;
}
