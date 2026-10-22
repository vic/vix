# bill: CI runner host, no users.
{ ren, ... }:
{
  ren.host.bill.system = ren.system.aarch64-linux;

  ren.aspects.bill-runner.nixos = {
    boot.loader.grub.enable = false;
    fileSystems."/".device = "/dev/null";
    fileSystems."/".fsType = "auto";
    users.users.runner.isNormalUser = true;
  };
  ren.aspects.bill = {
    at = ren.host.bill;
    includes = [ ren.aspects.bill-runner ];
  };
}
