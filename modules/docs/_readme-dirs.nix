# readme dirs (a fn of yen and vocabDirs): live table of modules/ and modules/vic/ directories, described by docs/_vocabulary-dirs.nix (docs/vocabulary.nix checks it).
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
  table =
    prefix: p: lines:
    yen.lib.batteries.docs.table [ "dir" "purpose" ] (
      map (n: [
        "`${prefix}${n}/`"
        lines.${n}
      ]) (dirsOf p)
    );
in
''
  import-tree loads every `.nix` file under `modules/`. Paths with `/_` are skipped (data files, payload).
  Dir names are for humans only. yen does not read them.

  ${table "modules/" ./.. vocabDirs.top}

  Inside `modules/vic/`:

  ${table "modules/vic/" ./../vic vocabDirs.vic}
''
