# Machines: the abstract kind of nixos hosts and macs, with typed facts community aspects key on; `place` finds the machine or home a scope lives on.
{
  ren,
  lib,
  opt,
  maybe,
  ...
}:
let
  inherit (ren.lib) anyOf and when;
  t = lib.types;
  place = s: s.host or s.mac or s.home or (if s ? parent then place s.parent else null); # nearest machine or home
  onDarwin = d: when (s: place s != null && (place s).system.darwin == d);
  on =
    kind: f:
    and [
      kind
      (when (s: f (place s)))
    ]; # machines of a kind whose facts satisfy f
in
{
  _module.args = {
    inherit place;
    darwin = onDarwin true;
    linux = onDarwin false;
    hostWhen = on ren.kinds.host;
    macWhen = on ren.kinds.mac;
  };

  ren.kinds.machine = {
    # abstract: no `below` lists it
    system = ren.kinds.system;
    channel = opt ren.kinds.channel ren.channel.unstable;
    users = opt (t.listOf ren.kinds.user) [ ];
    envs = opt (t.listOf ren.kinds.env) [ ]; # dev environments its users get (envs/env.nix)
    cpu = maybe (
      t.enum [
        "amd"
        "intel"
      ]
    );
    gpu = maybe (t.enum [ "nvidia" ]);
    wifi = maybe (t.enum [ "broadcom" ]);
    keyboard = maybe (t.enum [ "macos" ]); # remapped to mac-style keys
    firmware = maybe (t.enum [ "all" ]); # non-free firmware too
    form = maybe (
      t.enum [
        "laptop"
        "wsl"
        "iso"
      ]
    );
    workstation = opt t.bool false; # shared baseline: boot/audio/locale/nix config (macs: nix + darwin defaults)
    desktops = opt (t.listOf (
      t.enum [
        "niri"
        "kde"
        "xfce"
        "gnome"
      ]
    )) [ ];
    layouts = opt (t.listOf (t.enum [ "enthium" ])) [ ];
  };

  ren.aspects.hostname = {
    at = anyOf [
      ren.kinds.host
      ren.kinds.mac
    ];
    os =
      { name, ... }: # the machine scope's instance name
      {
        networking.hostName = name;
      };
  };
}
