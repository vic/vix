{ config, lib, ... }:
{
  den.aspects.vix.provides = { };
  _module.args.vix = config.den.aspects.vix.provides;
  flake.vix = config.den.aspects.vix.provides;
  imports = [ (lib.mkAliasOptionModule [ "vix" ] [ "den" "aspects" "vix" "provides" ]) ];
}
