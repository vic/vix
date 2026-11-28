# varda: mac.
{ yen, ... }:
{
  yen.mac.varda = {
    system = yen.system.aarch64-darwin;
    users = [ yen.user.vic ];
    trusted = true; # holds vic's secrets
    workstation = true;
    ciBroken = "openspec"; # its ci job may fail
  };
}
