# bombadil: the USB installer image (installer base comes from the installer role).
{ ren, ... }:
{
  ren.host.bombadil = {
    system = ren.system.x86_64-linux;
    users = [ ren.user.vic ];
  };

  ren.aspects.bombadil = {
    at = ren.host.bombadil;
    includes = [
      ren.aspects.graphical
      ren.aspects.trusted
      ren.aspects.live-dots
      ren.aspects.installer
      ren.aspects.installer-base
      ren.aspects.workstation
      ren.aspects.macbook
      ren.aspects.all-firmware
    ];
  };
}
