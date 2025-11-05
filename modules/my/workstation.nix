{ __findFile, ... }:
{
  my.workstation.provides = {
    # for real-world hw machine
    hw.includes = [
      <my.workstation/base>
      <vix.mexico>
      <vix.bootable>
      <vix.kvm-amd>
      <vix.niri-desktop>
      <vix.kde-desktop>
    ];

    vm.includes = [
      <my.workstation/base>
      <vix.installer>
    ];

    base.includes = [
      <vix.xfce-desktop>
      <vix.dev-laptop>
    ];
  };
}
