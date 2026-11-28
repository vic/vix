# bootable: systemd-boot, locale, X11 keyboard and pipewire, on workstation hosts.
{ yen, ... }:
{
  yen.aspects.bootable = {
    at = yen.kinds.host.where { workstation = true; };
    nixos =
      { lib, modulesPath, ... }:
      {
        imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        powerManagement.enable = true;

        networking.useDHCP = lib.mkDefault true;

        i18n.defaultLocale = "en_US.UTF-8";
        time.timeZone = "America/Mexico_City";

        services.xserver.enable = true;
        services.xserver.xkb = {
          layout = "us";
          variant = "";
        };

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
