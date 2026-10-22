# nienna: Intel macbook workstation.
{ ren, ... }:
{
  ren.host.nienna = {
    checkout = "/home/vic/hk/vix";
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
    workstation = true;
    cpu = "intel";
    wifi = "broadcom";
    keyboard = "macos";
    desktops = [ "xfce" ];
  };

  ren.aspects.nienna-hardware.nixos = {
    boot.initrd.availableKernelModules = [
      "uhci_hcd"
      "ehci_pci"
      "ahci"
      "firewire_ohci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/389d7756-a765-4be8-81eb-6712e893e705";
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/67E3-17ED";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    swapDevices = [ ];
  };

  ren.aspects.nienna = {
    at = ren.host.nienna;
    includes = [
      ren.aspects.trusted
      ren.aspects.nienna-hardware
    ];
  };
}
