# wl-broadcom: Broadcom STA wifi driver, on hosts with broadcom wifi.
{ sven, ... }:
{
  sven.aspects.wl-broadcom = {
    at = sven.lib.all [
      sven.helpers.linux
      (s: s.wifi == "broadcom")
    ];
    unfree = sven.helpers.allowUnfree [ "broadcom-sta" ];
    nixos =
      { lib, config, ... }:
      {
        boot.kernelModules = [ "wl" ];
        boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
        nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [ "broadcom-sta" ];
      };
  };
}
