# src links for the README: `at dir file needle text` links to the first line of <dir><file> that contains needle.
# The line is found at eval time, so links follow edits; a needle that is gone is an eval error.
rec {
  at =
    dir: file: needle: text:
    let
      lines = builtins.filter builtins.isString (
        builtins.split "\n" (builtins.readFile (../.. + "/${dir}${file}"))
      );
      has = l: builtins.replaceStrings [ needle ] [ "" ] l != l; # literal substring, no regex
      hits = builtins.filter (i: has (builtins.elemAt lines i)) (
        builtins.genList (i: i) (builtins.length lines)
      );
    in
    if hits == [ ] then
      throw "docs: `${needle}` not found in ${dir}${file}"
    else
      "[`${text}`](${dir}${file}#L${toString (builtins.head hits + 1)})";
  src = at "modules/"; # a file of the fleet
  top = at ""; # a file at the repo root (tests.nix, mcp/)
}
