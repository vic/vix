# wl-broadcom: Broadcom STA wifi driver, on hosts with yen.wifi.broadcom.
{ yen, ... }:
{
  yen.aspects.wl-broadcom = {
    at = yen.kinds.host.where { wifi = yen.wifi.broadcom; };
    unfree = [ "broadcom-sta" ];
    nixos =
      { lib, config, ... }:
      {
        boot.kernelModules = [ "wl" ];
        boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
        nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [ "broadcom-sta" ];
      };
  };
}
