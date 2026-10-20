# power: scx_lavd follows the power profile on laptops; thermald on intel laptops.
{ lib, ren, ... }:
let
  laptop = ren.lib.and [
    ren.kinds.host
    (ren.lib.when (s: s.host.form == "laptop"))
  ];
in
{
  ren.aspects.laptop-power = {
    at = laptop;
    # energy preference stays with power-profiles-daemon (laptop.nix): a second EPP writer would fight it.
    # sched_ext needs linux >= 6.12: the scx module asserts it, the unit skips without /sys/kernel/sched_ext
    nixos.services.scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopower" ];
    };
  };

  ren.aspects.laptop-thermald = {
    at = ren.lib.and [
      laptop
      (ren.lib.when (s: s.host.cpu == "intel"))
    ];
    nixos.services.thermald.enable = true;
  };
}
