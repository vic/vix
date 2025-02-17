{

  boot.initrd.availableKernelModules = [ "nvme" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/11e3ea02-38da-40a4-ae44-31d4ffa1443a";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B67C-E7E6";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/3ff7df03-0f14-4bb5-953c-0c43a103dfcd"; }
    ];

}