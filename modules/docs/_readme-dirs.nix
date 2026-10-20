# readme dirs (a fn of vocabDirs): live table of modules/ and modules/vic/ directories, checked against docs/_vocabulary-dirs.nix.
{ vocabDirs }:
let
  inherit (builtins)
    attrNames
    concatStringsSep
    elem
    filter
    readDir
    throw
    ;
  dirsOf =
    p:
    let
      e = readDir p;
    in
    filter (n: e.${n} == "directory") (attrNames e);
  # same guard style as readme-vocab: names every missing and stale line.
  described =
    what: names: lines:
    let
      missing = filter (n: !(lines ? ${n})) names;
      stale = filter (n: !(elem n names)) (attrNames lines);
    in
    if missing == [ ] && stale == [ ] then
      lines
    else
      throw "docs/_vocabulary-dirs.nix ${what}: missing [${toString missing}] stale [${toString stale}]";
  table =
    prefix: p: lines:
    concatStringsSep "\n" (
      [
        "| dir | purpose |"
        "| --- | --- |"
      ]
      ++ map (n: "| `${prefix}${n}/` | ${lines.${n}} |") (attrNames (described prefix (dirsOf p) lines))
    );
in
''
  ## Directory structure

  import-tree loads every `.nix` file under `modules/`. Paths with `/_` are skipped.
  Dir names are for humans only. Ren does not read them.

  ${table "modules/" ./.. vocabDirs.top}

  Inside `modules/vic/`:

  ${table "modules/vic/" ./../vic vocabDirs.vic}
''
