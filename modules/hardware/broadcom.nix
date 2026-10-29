# wl-broadcom: Broadcom STA wifi driver, on hosts with broadcom wifi.
{ yen, ... }:
{
  yen.aspects.wl-broadcom = {
    at = yen.lib.all [
      yen.helpers.linux
      (s: s.wifi == "broadcom")
    ];
    unfree = yen.helpers.allowUnfree [ "broadcom-sta" ];
    nixos =
      { lib, config, ... }:
      {
        boot.kernelModules = [ "wl" ];
        boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
        nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [ "broadcom-sta" ];
      };
  };
}
