# Option shorthands and the class-module wrapper, shared by every file (module args).
{ lib, ... }:
let
  opt = type: default: lib.mkOption { inherit type default; };
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
in
{
  _module.args = { inherit opt maybe mod; };
}
