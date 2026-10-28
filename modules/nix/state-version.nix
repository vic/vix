# State versions: defaults every os and home config starts from (a host may set its own).
{ sven, ... }:
let
  default = path: v: { lib, ... }: lib.setAttrByPath path (lib.mkDefault v);
in
{
  sven.aspects.nixos-state = {
    at = sven.helpers.linux;
    nixos = default [ "system" "stateVersion" ] "25.05";
  };
  sven.aspects.darwin-state = {
    at = sven.kinds.mac;
    darwin = default [ "system" "stateVersion" ] 6;
  };
  sven.aspects.home-state = {
    at = sven.kinds.user;
    homeManager = default [ "home" "stateVersion" ] "25.05";
  };
}
