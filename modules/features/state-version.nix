# State versions: defaults every os and home config starts from (a host may set its own).
{ lib, ren, ... }:
let
  vix = import ../_lib.nix { inherit lib; };
  default = path: v: vix.mod ({ lib, ... }: lib.setAttrByPath path (lib.mkDefault v));
in
{
  ren.aspects.nixos-state = {
    at = ren.kinds.host;
    nixos = default [ "system" "stateVersion" ] "25.05";
  };
  ren.aspects.darwin-state = {
    at = ren.kinds.mac;
    darwin = default [ "system" "stateVersion" ] 6;
  };
  ren.aspects.home-state = {
    at = ren.kinds.user;
    homeManager = default [ "home" "stateVersion" ] "25.05";
  };
}
