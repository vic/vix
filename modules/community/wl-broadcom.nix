# wl-broadcom: Broadcom STA wifi driver, on hosts with broadcom wifi.
{
  mod,
  hostWhen,
  allowUnfree,
  ...
}:
{
  ren.aspects.wl-broadcom = {
    at = hostWhen (h: h.wifi == "broadcom");
    unfree = allowUnfree [ "broadcom-sta" ];
    nixos = mod (
      { lib, config, ... }:
      {
        boot.kernelModules = [ "wl" ];
        boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
        nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [ "broadcom-sta" ];
      }
    );
  };
}
