# Machines: the abstract kind of nixos hosts and macs, with typed facts community aspects key on.
{
  ren,
  lib,
  ...
}:
let
  vix = ren.helpers;
  inherit (ren.lib) anyOf;
  t = lib.types;
in
{
  ren.kinds.machine = {
    # abstract: no `below` lists it
    system = ren.kinds.system;
    channel = vix.opt ren.kinds.channel ren.channel.unstable;
    users = vix.opt (t.listOf ren.kinds.user) [ ];
    cpu = vix.maybe (
      t.enum [
        "amd"
        "intel"
      ]
    );
    gpu = vix.maybe (t.enum [ "nvidia" ]);
    wifi = vix.maybe (t.enum [ "broadcom" ]);
    keyboard = vix.maybe (t.enum [ "macos" ]); # remapped to mac-style keys
    firmware = vix.maybe (t.enum [ "all" ]); # non-free firmware too
    form = vix.maybe (
      t.enum [
        "laptop"
        "wsl"
        "iso"
      ]
    );
    workstation = vix.opt t.bool false; # shared baseline: boot/audio/locale/nix config (macs: nix + darwin defaults)
    desktops = vix.opt (t.listOf (
      t.enum [
        "niri"
        "kde"
        "xfce"
        "gnome"
      ]
    )) [ ];
    layouts = vix.opt (t.listOf (t.enum [ "enthium" ])) [ ];
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
