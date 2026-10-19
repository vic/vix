# Option shorthands and the class-module wrapper, shared by every file (module args).
{ lib, ... }:
let
  opt = type: default: lib.mkOption { inherit type default; };
  maybe = type: opt (lib.types.nullOr type) null;
  # content `lib` is Ren's lib; a module that needs its class lib (mkIf, getExe, hm.dag) goes through `imports`.
  mod = m: { imports = [ m ]; };
in
{
  _module.args = { inherit opt maybe mod; };
}
