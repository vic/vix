{
  inputs,
  den,
  ...
}:
{
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "vix" true)
    (inputs.den.namespace "vic" false)
  ];

  config._module.args.__findFile = den.lib.__findFile;
}
