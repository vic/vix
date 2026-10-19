# mordor: workstation with an nvidia card.
{ ren, allowUnfree, ... }:
{
  ren.host.mordor = {
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
  };

  ren.aspects.mordor-hardware.nixos = {
    hardware.nvidia.prime.nvidiaBusId = "PCI:9:0:0";
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

  ren.aspects.mordor = {
    at = ren.host.mordor;
    unfree = allowUnfree [
      "nvidia-x11"
      "nvidia-settings"
    ];
    includes = [
      ren.aspects.graphical
      ren.aspects.trusted
      ren.aspects.live-dots
      ren.aspects.workstation
      ren.aspects.kvm-amd
      ren.aspects.nvidia
      ren.aspects.mordor-hardware
    ];
  };
}
