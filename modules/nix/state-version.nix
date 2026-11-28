# State versions: NixOS machines inherit `stateVersion` via `linux`; macs and homes use defaults.
{
  yen,
  types,
  ...
}:
let
  default =
    path: v:
    { lib, ... }:
    lib.setAttrByPath path (lib.mkDefault v);
in
{
  yen.kinds.linux.fields.stateVersion = types.opt types.str "25.05";

  yen.aspects.nixos-state = {
    at = yen.kinds.linux;
    nixos = { scope, ... }: { system.stateVersion = scope.stateVersion; };
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
