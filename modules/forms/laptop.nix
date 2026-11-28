# Laptop baseline: zram, earlyoom, fwupd, power-profiles-daemon, nvd activation diff.
{ yen, ... }:
{
  yen.aspects.laptop = {
    at = yen.kinds.host.where { form = yen.form.laptop; };
    nixos =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        services.journald.settings.Journal.SystemMaxUse = "500M";

        zramSwap.enable = true;
        zramSwap.memoryPercent = 25;
        services.earlyoom = {
          enable = true;
          freeSwapThreshold = 100;
          freeSwapKillThreshold = 100;
          freeMemThreshold = 5;
          freeMemKillThreshold = 2;
        };

        documentation.nixos.enable = false;
        documentation.info.enable = false;
        documentation.doc.enable = false;

        services.fwupd.enable = true;
        services.power-profiles-daemon.enable = lib.mkDefault true;
        networking.networkmanager.wifi.powersave = true;

        nix.daemonCPUSchedPolicy = "batch";
        nix.daemonIOSchedClass = "idle";

        system.activationScripts.diff = {
          supportsDryActivation = true;
          text = ''
            if [[ -e /run/current-system ]]; then
              ${lib.getExe pkgs.nvd} --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
            fi
          '';
        };
      };
  };
}
