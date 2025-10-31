{
  config,
  lib,
  ...
}:
{
  # create namespace
  den.aspects.vix.provides = { };
  # expose aspect-tree to public
  flake.vix = config.den.aspects.vix.provides;
  # easy access on modules
  _module.args.vix = config.den.aspects.vix.provides;
  # write directly to vix attribute
  imports = [ (lib.mkAliasOptionModule [ "vix" ] [ "den" "aspects" "vix" "provides" ]) ];
}
