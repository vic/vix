# readme dirs (a fn of vocabDirs): live table of modules/ and modules/vic/ directories, checked against docs/_vocabulary-dirs.nix.
{ vocabDirs }:
let
  inherit (builtins)
    attrNames
    concatStringsSep
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
    concatStringsSep "\n" (
      [
        "| dir | purpose |"
        "| --- | --- |"
      ]
      ++ map (n: "| `${prefix}${n}/` | ${lines.${n}} |") (described prefix (dirsOf p) lines)
    );
in
''
  import-tree loads every `.nix` file under `modules/`. Paths with `/_` are skipped.
  Dir names are for humans only. Ren does not read them.

  ${table "modules/" ./.. vocabDirs.top}

  Inside `modules/vic/`:

  ${table "modules/vic/" ./../vic vocabDirs.vic}
''
