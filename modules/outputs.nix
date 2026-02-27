{ lib, ... }:
{
  options.flake = lib.mkOption {
    default = { };
    type = lib.types.submodule {
      freeformType = lib.types.lazyAttrsOf lib.types.raw;
    };
  };
}
