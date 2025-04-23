#  nix build .#.nixosConfigurations.bombadil.config.system.build.isoImage
{
  modulesPath,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = with inputs.self.nixosModules; [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    nix-features
    vic
    vic-autologin
    macos-keys
    kvm-intel
    wl-broadcom
    all-firmware
    xfce-desktop
    ./static.nix
  ];

  lib.isoFileSystems."/home/vic" = {
    device = "/dev/disk/by-label/vic";
    fsType = "ext4";
  };

  users.users.vic.uid = 1000;
  users.users.nixos.uid = 1001;

  vix.features.macos-keys.enable = true;

  isoImage.edition = lib.mkDefault config.networking.hostName;
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkImageMediaOverride false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  services.pulseaudio.enable = false;

}
