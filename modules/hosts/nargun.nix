{ vix, ... }:
{
  vix.nargun.includes = [
    vix.nargun._.base
    vix.nargun._.hw
  ];

  vix.nargun-vm.includes = [
    vix.nargun._.base
    vix.nargun._.vm
  ];

  vix.nargun.provides = {
    # for real-world hw machine
    hw.includes = [
      vix.mexico
      vix.bootable
      vix.kvm-amd
      vix.niri-desktop
      vix.kde-desktop
    ];

    vm.includes = [
      vix.xfce-desktop
    ];

    base.includes = [
      vix.dev-laptop
    ];
  };
}
