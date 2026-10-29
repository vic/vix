# varda: mac.
{ yen, ... }:
{
  yen.mac.varda = {
    system = yen.system.aarch64-darwin;
    users = [ yen.user.vic ];
    workstation = true;
    ciBroken = "openspec"; # its ci job may fail
  };
  yen.aspects.trusted.at = yen.mac.varda;
}
