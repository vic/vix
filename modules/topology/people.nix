# People: the user kind (identity, login shell, admin) and how a machine spawns its users.
{
  lib,
  opt,
  maybe,
  ...
}:
let
  t = lib.types;
in
{
  _module.args.usersOf =
    m:
    builtins.listToAttrs (
      map (u: {
        inherit (u) name;
        value = u;
      }) m.users
    );

  ren.kinds.user = {
    fullName = t.str;
    email = t.str;
    shell = maybe t.str;
    admin = opt t.bool false;
  };
}
