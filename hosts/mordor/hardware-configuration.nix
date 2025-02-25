# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./nvidia.nix
    ./amd.nix
    ./filesystems.nix
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
}
