# nix-darwin: the mac kind and the darwin class.
{ lib, ren, ... }:
let
  vix = import ../_lib.nix { inherit lib; };
in
{
  ren.kinds.mac = {
    is = ren.kinds.machine;
    below = [ ren.kinds.user ];
    spawns.user = s: vix.usersOf s.mac;
  };

  ren.classes.darwin = {
    at = ren.kinds.mac;
    into = { mac, ... }: ms: {
      darwinConfigurations.${mac.name} = mac.channel.darwin.lib.darwinSystem {
        system = mac.system.name;
        modules = ms;
      };
    };
  };
}
