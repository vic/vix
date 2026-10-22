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
      zramSwap.memoryPercent = 25; # zram pages sit in the same RAM; 50% swaps into its own headroom
      services.earlyoom = {
        enable = true;
        # hibernate swap is not working swap: swap arm always true, kill on memory alone.
        freeSwapThreshold = 100;
        freeSwapKillThreshold = 100;
        freeMemThreshold = 5;
        freeMemKillThreshold = 2;
      };

      # Skip manual rebuilds on every switch; man stays.
      documentation.nixos.enable = false;
      documentation.info.enable = false;
      documentation.doc.enable = false;

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
