# Machines: the data kind host, guest and mac copy their fields from, with typed facts hardware aspects key on.
{ yen, lib, ... }:
let
  inherit (yen.lib) opt maybe derive;
  inherit (yen.helpers) listOf enum;
  # the nixos-facter report of a host with hosts/<name>/_nixos/facter.json (null otherwise)
  facter =
    m:
    let
      f = ../hosts + "/${m.name}/_nixos/facter.json";
    in
    if m.kind == "host" && builtins.pathExists f then
      (builtins.fromJSON (builtins.readFile f)).hardware
    else
      null;
  vendors = {
    AuthenticAMD = "amd";
    GenuineIntel = "intel";
  };
  facterCpu =
    m:
    let
      v = if facter m == null then null else (lib.head ((facter m).cpu or [ { } ])).vendor_name or null;
    in
    if v == null then null else vendors.${v} or null;
  facterGpu =
    m:
    if
      facter m != null
      && lib.any (g: lib.hasInfix "NVIDIA" (g.vendor.name or "")) ((facter m).graphics_card or [ ])
    then
      "nvidia"
    else
      null;
in
{
  yen.kinds.machine.fields = {
    system = yen.kinds.system;
    channel = opt yen.kinds.channel yen.channel.unstable;
    users = opt (listOf yen.kinds.user) [ ];
    # a facter report decides when the host file does not say (an explicit value, null too, wins)
    cpu = derive (maybe (enum [
      "amd"
      "intel"
    ])) facterCpu;
    gpu = derive (maybe (enum [ "nvidia" ])) facterGpu;
    wifi = maybe (enum [ "broadcom" ]);
    keyboard = maybe (enum [ "macos" ]); # remapped to mac-style keys
    firmware = maybe (enum [ "all" ]); # non-free firmware too
    form = maybe (enum [
      "laptop"
      "wsl"
      "iso"
    ]);
    workstation = opt lib.types.bool false; # shared baseline: boot/audio/locale/nix config (macs: nix + darwin defaults)
    desktops = opt (listOf (enum [
      "niri"
      "kde"
      "xfce"
      "gnome"
    ])) [ ];
    layouts = opt (listOf (enum [ "enthium" ])) [ ];
  };

  yen.aspects.hostname = {
    at = yen.helpers.machines;
    os = { scope, ... }: { networking.hostName = scope.name; };
  };
}
