# vix helpers: pure fns shared by every fleet file as `ren.helpers` (`vix = ren.helpers;`).
{ lib, ... }:
let
  opt = type: default: lib.mkOption { inherit type default; };
  place = s: s.host or s.mac or s.home or (if s ? parent then place s.parent else null); # nearest machine or home
in
{
  ren.helpers = {
    inherit opt place;
    maybe = type: opt (lib.types.nullOr type) null;
    # unfree channel emission: `unfree = vix.allowUnfree [ "name" ];`
    allowUnfree = names: lib.genAttrs names (_: true);
    # a machine's users by name (spawns.user of host, mac, guest)
    usersOf =
      m:
      builtins.listToAttrs (
        map (u: {
          inherit (u) name;
          value = u;
        }) m.users
      );
    # each flake's outputs for the system of `pkgs`: `(vix.perSystem pkgs inputs.jjui).packages.jjui`
    perSystem = pkgs: builtins.mapAttrs (_: v: v.${pkgs.stdenv.hostPlatform.system} or v);
  };
}
