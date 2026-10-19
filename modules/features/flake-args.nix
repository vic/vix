# Flake args: every os and home config gets inputs' and self' (each flake's outputs for its system).
{
  ren,
  inputs,
  place,
  ...
}:
let
  perSystem = sys: builtins.mapAttrs (_: v: if builtins.isAttrs v && v ? ${sys} then v.${sys} else v);
  argsFor = m: {
    _module.args."inputs'" = builtins.mapAttrs (_: perSystem m.system.name) inputs;
    _module.args."self'" = perSystem m.system.name inputs.self;
  };
in
{
  ren.aspects.nixos-args = {
    at = ren.kinds.host;
    nixos = { host, ... }: argsFor host;
  };
  ren.aspects.darwin-args = {
    at = ren.kinds.mac;
    darwin = { mac, ... }: argsFor mac;
  };
  ren.aspects.home-args = {
    at = ren.kinds.user;
    homeManager = { parent, ... }: argsFor (place parent);
  };
}
