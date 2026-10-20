# mordor: workstation with an nvidia card.
{ ren, ... }:
{
  ren.host.mordor = {
    checkout = "/home/vic/hk/vix";
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
    workstation = true;
    cpu = "amd";
    gpu = "nvidia";
    desktops = [ "xfce" ];
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
    includes = [
      ren.aspects.trusted
      ren.aspects.mordor-hardware
    ];
  };
}
