# varda: mac.
{ sven, ... }:
{
  sven.mac.varda = {
    system = sven.system.aarch64-darwin;
    users = [ sven.user.vic ];
    workstation = true;
    ciBroken = "openspec"; # its ci job may fail
  };
  sven.aspects.trusted.at = sven.mac.varda;
}
