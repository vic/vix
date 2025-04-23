{
  flake.modules.nixos.mordor = {

    boot.initrd.availableKernelModules = [ "nvme" ];

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

    swapDevices = [
      { device = "/dev/disk/by-label/swap"; }
    ];

  };
}
