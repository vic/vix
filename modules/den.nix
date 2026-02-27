{
  inputs,
  den,
  lib,
  vix,
  ...
}:
let
in
{
  _module.args.__findFile = den.lib.__findFile;
  imports = lib.optionals (inputs ? den) [
    (inputs.den.namespace "vix" true)
    (inputs.den.namespace "vic" false)
  ];
}
