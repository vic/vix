# wl-broadcom: Broadcom STA wifi driver.
{ mod, ... }:
{
  ren.aspects.wl-broadcom.nixos = mod (
    { lib, config, ... }:
    {
      boot.kernelModules = [ "wl" ];
      boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
      nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [ "broadcom-sta" ];
    }
  );
}
