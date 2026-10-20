# vix lib: pure helpers, imported explicitly (`vix = import ../_lib.nix { inherit lib; };`); import-tree skips `/_` paths.
{ lib }:
let
  opt = type: default: lib.mkOption { inherit type default; };
  place = s: s.host or s.mac or s.home or (if s ? parent then place s.parent else null); # nearest machine or home
in
{
  inherit opt place;
  maybe = type: opt (lib.types.nullOr type) null;
  # Ren binds its own `lib` into content fns, even inside `imports` (vic/ren#20). Hide the `lib` formal from Ren:
  # the module system always passes the class lib, and Ren binds no name the module does not declare.
  mod = m: {
    imports = [
      {
        __functor = _: m;
        __functionArgs = removeAttrs (builtins.functionArgs m) [ "lib" ];
      }
    ];
  };
  # unfree channel emission: `unfree = vix.allowUnfree [ "name" ];`
  allowUnfree =
    names:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = true;
      }) names
    );
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
}
