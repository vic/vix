# power: scx_lavd follows the power profile on laptops; thermald on intel laptops.
{ yen, ... }:
{
  yen.aspects.laptop-power = {
    at = yen.aspects.laptop;
    # energy preference stays with power-profiles-daemon (laptop.nix): a second EPP writer would fight it.
    # sched_ext needs linux >= 6.12: the scx module asserts it, the unit skips without /sys/kernel/sched_ext
    nixos.services.scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopower" ];
    };
  };

  yen.aspects.laptop-thermald = {
    at = yen.lib.all [
      yen.aspects.laptop
      (s: s.cpu == "intel")
    ];
    nixos.services.thermald.enable = true;
  };
}
