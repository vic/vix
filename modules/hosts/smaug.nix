# smaug: macbook workstation with nvidia.
{ ren, ... }:
{
  ren.host.smaug = {
    checkout = "/home/vic/hk/vix";
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
    workstation = true;
    cpu = "intel";
    gpu = "nvidia";
    wifi = "broadcom";
    keyboard = "macos";
    firmware = "all";
    desktops = [ "xfce" ];
  };

  ren.aspects.smaug-hardware.nixos = {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "usb_storage"
      "sd_mod"
    ];
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    fileSystems."/home" = {
      device = "/dev/disk/by-label/home";
      fsType = "ext4";
    };
    swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
  };

  ren.aspects.smaug = {
    at = ren.host.smaug;
    includes = [
      ren.aspects.trusted
      ren.aspects.smaug-hardware
    ];
  };
}
