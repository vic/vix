{ den, vix, ... }:
{
  den.aspects.mordor = {
    includes = [
      vix.bootable
      vix.nix-settings
      vix.kvm-amd
      vix.nvidia
      vix.xfce-desktop
      (den.provides.unfree [
        "nvidia-x11"
        "nvidia-settings"
      ])
    ];

    nixos.hardware.nvidia.prime.nvidiaBusId = "PCI:9:0:0";

    nixos = {
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
      fileSystems."/home" = {
        device = "/dev/disk/by-label/home";
        fsType = "ext4";
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-label/BOOT";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };
      swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];
    };
  };
}
