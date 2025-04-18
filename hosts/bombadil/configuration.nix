#  nix build .#.nixosConfigurations.bombadil.config.system.build.isoImage
{
  modulesPath,
  pkgs,
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
    ./static.nix
  ];

  lib.isoFileSystems."/home/vic" = {
    device = "/dev/disk/by-label/vic";
    fsType = "ext4";
  };


  vix.features.macos-keys.enable = true;

  isoImage.edition = lib.mkDefault config.networking.hostName;
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkImageMediaOverride false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  services.pulseaudio.enable = false;

  # https://gist.github.com/nat-418/1101881371c9a7b419ba5f944a7118b0
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager = {
    defaultSession = "xfce";
    enable = true;
  };
}
