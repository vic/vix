# nienna: Intel macbook workstation.
{ ren, allowUnfree, ... }:
{
  ren.host.nienna = {
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
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
    unfree = allowUnfree [ "broadcom-sta" ];
    includes = [
      ren.aspects.graphical
      ren.aspects.trusted
      ren.aspects.live-dots
      ren.aspects.workstation
      ren.aspects.macbook
      ren.aspects.nienna-hardware
    ];
  };
}
