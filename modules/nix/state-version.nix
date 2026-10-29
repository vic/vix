# State versions: defaults every os and home config starts from (a host may set its own).
{ yen, ... }:
let
  default = path: v: { lib, ... }: lib.setAttrByPath path (lib.mkDefault v);
in
{
  yen.aspects.nixos-state = {
    at = yen.helpers.linux;
    nixos = default [ "system" "stateVersion" ] "25.05";
  };
  yen.aspects.darwin-state = {
    at = yen.kinds.mac;
    darwin = default [ "system" "stateVersion" ] 6;
  };
  yen.aspects.home-state = {
    at = yen.kinds.user;
    homeManager = default [ "home" "stateVersion" ] "25.05";
  };
}
