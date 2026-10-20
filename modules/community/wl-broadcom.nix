# wl-broadcom: Broadcom STA wifi driver, on hosts with broadcom wifi.
{
  ren,
  ...
}:
let
  vix = ren.helpers;
in
{
  ren.aspects.wl-broadcom = {
    at = ren.lib.and [
      ren.kinds.host
      (ren.lib.when (s: s.host.wifi == "broadcom"))
    ];
    unfree = vix.allowUnfree [ "broadcom-sta" ];
    nixos =
      { lib, config, ... }:
      {
        boot.kernelModules = [ "wl" ];
        boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
        nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [ "broadcom-sta" ];
      };
  };
}
