# smaug hardware (was the smaug-hardware aspect); hosts/autoinclude.nix imports it.
{ ... }:
{
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
}
