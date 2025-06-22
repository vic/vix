{
  flake.modules.nixos.wl-broadcom =
    { config, ... }:
    {
      boot.kernelModules = [ "wl" ];
      boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    };
}
