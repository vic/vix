#  nix build .#.nixosConfigurations.bombadil.config.system.build.isoImage
{ inputs, ... }:
{
  flake.modules.nixos.bombadil =
    {
      modulesPath,
      config,
      lib,
      ...
    }:
    {
      imports = with inputs.self.modules.nixos; [
        "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix"
        vic
        macos-keys
        kvm-intel
        wl-broadcom
        all-firmware
        xfce-desktop
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
}
