{
  lib,
  vix,
  ...
}:
{
  den.aspects.bombadil = {
    includes = [
      vix.bootable
      vix.nix-settings
      vix.macos-keys
      vix.kvm-intel
      vix.wl-broadcom
      vix.all-firmware
      vix.xfce-desktop
    ];

    nixos =
      { modulesPath, config, ... }:
      {
        imports = [
          "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix"
        ];

        lib.isoFileSystems."/home/vic" = {
          device = "/dev/disk/by-label/vic";
          fsType = "ext4";
        };

        users.users.vic.uid = 1000;
        users.users.nixos.uid = 1001;

        isoImage.edition = lib.mkDefault config.networking.hostName;
        networking.networkmanager.enable = true;
        networking.wireless.enable = lib.mkImageMediaOverride false;

        hardware.bluetooth.enable = true;
        hardware.bluetooth.powerOnBoot = true;
        services.blueman.enable = true;
        services.pulseaudio.enable = false;
      };
  };
}
