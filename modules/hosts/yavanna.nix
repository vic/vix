# yavanna: mac.
{ ren, ... }:
{
  ren.mac.yavanna = {
    system = ren.system.x86_64-darwin;
    users = [ ren.user.vic ];
    workstation = true;
  };

  ren.aspects.yavanna = {
    at = ren.mac.yavanna;
    includes = [
      ren.aspects.trusted
      ren.aspects.live-dots
    ];
  };
}
