# nargun: workstation with KDE and niri.
{ ren, ... }:
{
  ren.host.nargun = {
    checkout = "/home/vic/hk/vix";
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
    workstation = true;
    cpu = "amd";
    keyboard = "macos";
    desktops = [
      "xfce"
      "kde"
      "niri"
    ];
    layouts = [ "enthium" ];
  };

  ren.aspects.nargun-hardware.nixos = {
    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/5e0a5652-9af6-4590-9bd1-be059e339b84";
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/3902-2085";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    swapDevices = [
      { device = "/dev/disk/by-uuid/3be2776b-3153-443b-95b8-0fbd06becb75"; }
    ];
  };

  ren.aspects.nargun = {
    at = ren.host.nargun;
    includes = [
      ren.aspects.trusted
      ren.aspects.nargun-hardware
    ];
  };
}
