{
  flake.modules.nixos.smaug = {

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "usb_storage"
      "sd_mod"
    ];
  };
}
