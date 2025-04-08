# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ ... }:

{

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/28a29cc4-7325-4911-a96a-9d82d1fb2021";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/856A-9AB5";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/fc6e67f6-3b0f-4a6b-b7ee-6977b5fc98d6";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/6f9b9136-d3aa-4c2d-9e7e-b5aea574bca0"; }
  ];

}
