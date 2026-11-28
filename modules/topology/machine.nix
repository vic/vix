# Machines & ref-typed hardware enums (zero strings!):
# Inheritance hierarchy: place -> machine -> { mac, linux -> { host, guest } }.
{
  yen,
  types,
  lib,
  ...
}:
let
  b = builtins;
  facterOf =
    h:
    (f: if b.pathExists f then (b.fromJSON (b.readFile f)).hardware else null) (
      ../hosts/_facter + "/${h.name}.json"
    );

  vendors = {
    AuthenticAMD = yen.cpu.amd;
    GenuineIntel = yen.cpu.intel;
  };

  facterCpu =
    h:
    (
      hw:
      if hw == null then
        null
      else
        (v: if v == null then null else vendors.${v} or null) (
          (lib.head (hw.cpu or [ { } ])).vendor_name or null
        )
    )
      (facterOf h);

  facterGpu =
    h:
    (
      hw:
      if
        hw != null && lib.any (g: lib.hasInfix "NVIDIA" (g.vendor.name or "")) (hw.graphics_card or [ ])
      then
        yen.gpu.nvidia
      else
        null
    )
      (facterOf h);
in
{
  # ── Ref-typed hardware, form, desktop, and layout data kinds (zero string enums!) ──
  yen.kinds.cpu = { };
  yen.cpu.amd = { };
  yen.cpu.intel = { };

  yen.kinds.gpu = { };
  yen.gpu.nvidia = { };

  yen.kinds.wifi = { };
  yen.wifi.broadcom = { };

  yen.kinds.keyboard = { };
  yen.keyboard.macos = { };

  yen.kinds.firmware = { };
  yen.firmware.all = { };

  yen.kinds.form = { };
  yen.form.laptop = { };
  yen.form.wsl = { };
  yen.form.iso = { };

  yen.kinds.desktop = { };
  yen.desktop.niri = { };
  yen.desktop.kde = { };
  yen.desktop.xfce = { };
  yen.desktop.gnome = { };

  yen.kinds.layout = { };
  yen.layout.enthium = { };

  # ── Kind inheritance via `extends` (eliminates `_on.nix` and manual field copying!) ──
  yen.kinds.machine = {
    extends = yen.kinds.place;
    fields = {
      users = types.opt (types.listOf yen.kinds.user) [ ];
      workstation = types.opt types.bool false;
      sharedPkgs = types.opt types.bool false;
      impermanence = {
        enable = types.opt types.bool false;
        wipeRoot = types.opt types.bool false;
      };
    };
  };

  yen.kinds.linux = {
    extends = yen.kinds.machine;
  };

  yen.kinds.host = {
    extends = yen.kinds.linux;
    fields = {
      cpu = types.derive (types.maybe yen.kinds.cpu) facterCpu;
      gpu = types.derive (types.maybe yen.kinds.gpu) facterGpu;
      wifi = types.maybe yen.kinds.wifi;
      keyboard = types.maybe yen.kinds.keyboard;
      firmware = types.maybe yen.kinds.firmware;
      form = types.maybe yen.kinds.form;
      desktops = types.opt (types.listOf yen.kinds.desktop) [ ];
      layouts = types.opt (types.listOf yen.kinds.layout) [ ];
    };
  };

  yen.kinds.guest.extends = yen.kinds.linux;
  yen.kinds.mac.extends = yen.kinds.machine;

  yen.aspects.hostname = {
    at = yen.kinds.machine;
    os = { machine, ... }: { networking.hostName = machine.name; };
  };
}
