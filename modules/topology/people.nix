# People: the user kind (identity, login shell, admin), vic, and the user pools that features fill.
{ yen, lib, ... }:
let
  inherit (yen.lib) opt maybe reduce;
  # an element is a list of strings; the reader gets them unique, first-seen order
  list = {
    reduce = yen.helpers.flat;
    of = yen.helpers.listOf lib.types.str;
  };
  # same elements, sorted: permission rules read the same whatever order the files load in
  sorted = {
    reduce = {
      name = "sorted";
      __functor = _: es: {
        value = lib.sort lib.lessThan (lib.unique (lib.concatMap (e: e.value) es));
        errors = [ ];
      };
    };
    inherit (list) of;
  };
in
{
  yen.kinds.user = {
    fields = {
      fullName = lib.types.str;
      email = lib.types.str;
      shell = maybe lib.types.str;
      admin = opt lib.types.bool false;
    };
    # read by one consumer aspect each: fish (vic/shell), git (vic/vcs), ai-claude (vic/ai)
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
