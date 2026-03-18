{ lib, ... }:
{
  vix.bootable = {
    nixos =
      { modulesPath, ... }:
      {
        imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        powerManagement.enable = true;

        networking.networkmanager.enable = true;
        networking.useDHCP = lib.mkDefault true;

        i18n.defaultLocale = "en_US.UTF-8";
        time.timeZone = "America/Mexico_City";

        services.xserver.enable = true;
        services.xserver.xkb = {
          layout = "us";
          variant = "";
        };

        hardware.bluetooth.enable = true;
        hardware.bluetooth.powerOnBoot = true;
        services.pulseaudio.enable = false;
        services.blueman.enable = true;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };
      };
  };
}
