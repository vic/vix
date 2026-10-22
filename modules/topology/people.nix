# People: the user kind (identity, login shell, admin) and how a machine spawns its users.
{
  lib,
  ren,
  ...
}:
let
  vix = ren.helpers;
  t = lib.types;
in
{
  ren.kinds.user = {
    fullName = t.str;
    email = t.str;
    shell = vix.maybe t.str;
    admin = vix.opt t.bool false;
  };
}
