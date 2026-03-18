{ den, vix, ... }:
{
  den.aspects.nienna = {
    includes = [
      vix.bootable
      vix.nix-settings
      vix.xfce-desktop
      vix.macos-keys
      vix.kvm-intel
      vix.wl-broadcom
      (den.provides.unfree [ "broadcom-sta" ])
    ];

    nixos = {
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
  };
}
