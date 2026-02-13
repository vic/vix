# helpers for debugging from repl.
{
  den,
  inputs,
  lib,
  ...
}:
let

  debug.evalAspect =
    aspect: class:
    let
      resolved = aspect.resolve { inherit class; };
      evaled = lib.evalModules { modules = [ resolved ]; };
    in
    evaled.config;

in
{
  options.inputs = lib.mkOption {
    type = lib.types.raw;
    default = inputs;
  };
  options.debug = lib.mkOption {
    type = lib.types.raw;
    default = debug;
  };
}
