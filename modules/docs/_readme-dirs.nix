# readme dirs (a fn of yen and vocabDirs): live table of modules/ and modules/vic/ directories, checked against docs/_vocabulary-dirs.nix.
{ yen, vocabDirs }:
let
  inherit (builtins)
    attrNames
    filter
    readDir
    ;
  dirsOf =
    p:
    let
      e = readDir p;
    in
    filter (n: e.${n} == "directory") (attrNames e);
  described = import ./_described.nix "_vocabulary-dirs.nix";
  table =
    prefix: p: lines:
    yen.lib.batteries.docs.table [ "dir" "purpose" ] (
      map (n: [
        "`${prefix}${n}/`"
        lines.${n}
      ]) (described prefix (dirsOf p) lines)
    );
in
''
  import-tree loads every `.nix` file under `modules/`. Paths with `/_` are skipped (data files, payload).
  Dir names are for humans only. yen does not read them.

  ${table "modules/" ./.. vocabDirs.top}

  Inside `modules/vic/`:

  ${table "modules/vic/" ./../vic vocabDirs.vic}
''
