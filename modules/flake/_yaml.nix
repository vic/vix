# yaml: render attrs, lists, strings, bools as block YAML (strings are JSON-quoted, which YAML accepts).
let
  scalar = v: !(builtins.isAttrs v || builtins.isList v) || v == [ ] || v == { };
  one =
    v:
    if v == [ ] then
      "[]"
    else if v == { } then
      "{}"
    else
      builtins.toJSON v;
  pad = n: builtins.concatStringsSep "" (builtins.genList (_: "  ") n);
  render =
    n: v:
    if builtins.isAttrs v then
      builtins.concatStringsSep "\n" (
        map (
          k:
          if scalar v.${k} then "${pad n}${k}: ${one v.${k}}" else "${pad n}${k}:\n${render (n + 1) v.${k}}"
        ) (builtins.attrNames v)
      )
    else
      builtins.concatStringsSep "\n" (
        map (
          x:
          if scalar x then
            "${pad n}- ${one x}"
          else
            "${pad n}- ${builtins.substring (2 * (n + 1)) (-1) (render (n + 1) x)}"
        ) v
      );
in
v: render 0 v + "\n"
