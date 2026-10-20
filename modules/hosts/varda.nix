# varda: mac.
{ ren, ... }:
{
  ren.mac.varda = {
    checkout = "/home/vic/hk/vix";
    system = ren.system.aarch64-darwin;
    users = [ ren.user.vic ];
    workstation = true;
  };

  ren.aspects.varda = {
    at = ren.mac.varda;
    includes = [
      ren.aspects.trusted
    ];
  };
}
