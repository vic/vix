# vocabulary guard of the readme tables: the live names, or an eval error naming every missing and stale line of `docs/<file>`.
file: what: names: lines:
let
  missing = builtins.filter (n: !(lines ? ${n})) names;
  stale = builtins.filter (n: !(builtins.elem n names)) (builtins.attrNames lines);
in
if missing == [ ] && stale == [ ] then
  names
else
  throw "docs/${file} ${what}: missing [${toString missing}] stale [${toString stale}]"
