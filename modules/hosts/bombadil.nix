{
  lib,
  den,
  vix,
  ...
}:
{
  den.aspects.bombadil.includes = [
    vix.workstation
    vix.macbook
    vix.all-firmware

    den.aspects.bombadil.installer
  ];

  # The USB installer image: installer base plus the live-session users.
  den.aspects.bombadil.installer.nixos =
    { modulesPath, config, ... }:
    {
      imports = [
        "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix"
      ];

      system.stateVersion = "26.05";

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
}
