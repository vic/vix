top@{lib, config, inputs, self, ...}: let
  inherit (config.vix.lib) dirApply;
  inherit (lib) pipe mapAttrs types mkOption;

  mkChannels = sys@{system, ...}: mapAttrs (name: f: f sys) config.vix.channels;

in {
  options.vix.channels = mkOption {
    description = "nixpkgs distributions";
    type = types.lazyAttrsOf (types.functionTo types.unspecified);
    default = dirApply (f: import f top) "${config.vix.self}/channels";
  };

  config.perSystem = sys@{system, ...}: {
    _module.args.channels' = mkChannels sys;
  };
}