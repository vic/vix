# varda: mac.
{ ren, ... }:
{
  ren.mac.varda = {
    system = ren.system.aarch64-darwin;
    users = [ ren.user.vic ];
    workstation = true;
  };

  ren.aspects.varda = {
    at = ren.mac.varda;
    includes = [
      ren.aspects.trusted
      ren.aspects.live-dots
    ];
  };
}
