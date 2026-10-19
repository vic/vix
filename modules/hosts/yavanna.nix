# yavanna: mac.
{ ren, ... }:
{
  ren.mac.yavanna = {
    system = ren.system.x86_64-darwin;
    users = [ ren.user.vic ];
  };

  ren.aspects.yavanna = {
    at = ren.mac.yavanna;
    includes = [
      ren.aspects.graphical
      ren.aspects.trusted
      ren.aspects.live-dots
      ren.aspects.nix-settings
      ren.aspects.darwin-base
    ];
  };
}
