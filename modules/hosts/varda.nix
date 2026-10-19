# varda: mac.
{ ren, ... }:
{
  ren.mac.varda = {
    system = ren.system.aarch64-darwin;
    users = [ ren.user.vic ];
  };

  ren.aspects.varda = {
    at = ren.mac.varda;
    includes = [
      ren.aspects.graphical
      ren.aspects.trusted
      ren.aspects.live-dots
      ren.aspects.nix-settings
      ren.aspects.darwin-base
    ];
  };
}
