{ __findFile, ... }:
{
  my.workstation.provides = {
    # for real-world hw machine
    hw.includes = [
      <my.workstation/base>

      <vix.bootable>
      <vix.kde-desktop>
      <vix.kvm-amd>
      <vix.mexico>
      <vix.niri-desktop>
    ];

    vm.includes = [
      <my.workstation/base>

      <vix.installer>
    ];

    base.includes = [
      <vix.dev-laptop>
      <vix.xfce-desktop>
    ];
  };
}
