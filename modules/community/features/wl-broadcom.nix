{
  flake.modules.nixos.wl-broadcom =
    { lib, config, ... }:
    {
      boot.kernelModules = [ "wl" ];
      boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
      nixpkgs.config.allowInsecurePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "broadcom-sta"
        ];
    };
}
