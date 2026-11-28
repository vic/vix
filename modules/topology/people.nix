# People: the user kind (identity, login shell, admin), vic, and the user pools that features fill.
{
  types,
  reduce,
  lib,
  ...
}:
let
  list = {
    reduce = reduce.flat;
    of = types.listOf types.str;
  };
  sorted = {
    reduce = es: {
      value = lib.sort lib.lessThan (lib.unique (lib.concatMap (e: e.value) es));
      errors = [ ];
    };
    inherit (list) of;
  };
in
{
  yen.kinds.user = {
    fields = {
      fullName = types.str;
      email = types.str;
      shell = types.maybe types.str;
      admin = types.opt types.bool false;
    };
    sinks = {
      fish-functions.reduce = reduce.merge;
      git-ignores = list;
      claude-allow = sorted;
    };
  };

  yen.user.vic = {
    fullName = "Victor Borja";
    email = "vborja@apache.org";
    shell = "fish";
    admin = true;
  };
}
