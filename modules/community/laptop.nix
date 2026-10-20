{ ren, ... }:
{
  # Laptop baseline. Ideas from sini core/{systemd,perf,nix,system,network}.
  ren.aspects.laptop.at = ren.lib.and [
    ren.kinds.host
    (ren.lib.when (s: s.host.form == "laptop"))
  ];
  ren.aspects.laptop.nixos =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      services.journald.settings.Journal.SystemMaxUse = "500M";

      # Swap partition (hibernate) stays; zram takes the first pages.
      zramSwap.enable = true;
      zramSwap.memoryPercent = 50; # the nixpkgs default, explicit
      services.earlyoom = {
        enable = true;
        freeSwapThreshold = 10; # explicit: both free mem and free swap must fall below 10%
      };

      services.fwupd.enable = true;
      services.power-profiles-daemon.enable = lib.mkDefault true;
      networking.networkmanager.wifi.powersave = true;

      # Nix builds yield to the desktop.
      nix.daemonCPUSchedPolicy = "batch";
      nix.daemonIOSchedClass = "idle";

      # Print the closure diff on every switch.
      system.activationScripts.diff = {
        supportsDryActivation = true;
        text = ''
          if [[ -e /run/current-system ]]; then
            ${lib.getExe pkgs.nvd} --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
          fi
        '';
      };
    };
}
