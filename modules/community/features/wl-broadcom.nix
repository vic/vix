{
  flake.modules.nixos.wl-broadcom =
    { config, ... }:
    {
      boot.kernelModules = [ "wl" ];
      boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
      nixpkgs.config.permittedInsecurePackages = [
        "broadcom-sta-6.30.223.271-57-6.12.40"
      ];
    };
}
