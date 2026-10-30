# Stored queries: named questions with parameters; an agent lists them (`queries`) and calls `ask name args`.
# - aspectsOn { name }    the aspects active at a machine or home, and at each scope below it (its users), by scope id
# - whoInstalls { pkg }   aspects whose files name `<x>.pkg`, and the scopes where each is active
# - unfreeOn { name }     the aspects that allow an unfree package at a machine or home or at its users, and where
# - portsOf { name }      the ports (`ports` sink) of a machine or home and of its users, each with its receiver scope id
# - featuresOf { vim }    a vim profile's features, and the aspects that give it nvf modules (x86_64-linux)
# - inputsOf { aspect }   the flake inputs an aspect declares on the flake-file sink
{ yen, lib, ... }:
let
  places = [
    "host"
    "mac"
    "guest"
    "home"
  ];
  activeAt = r: id: lib.filter (n: r.active.${n}.${id}) (lib.attrNames r.active);
  unknown = what: n: ns: {
    error = "no ${what} ${n}";
    near = lib.filter (x: lib.hasPrefix (lib.substring 0 2 n) x) ns;
  };
  # the ids of every machine or home named `name` and of each scope below it; [ ] when there is none
  under =
    r: name:
    lib.concatMap (
      p: map (s: s.id) (lib.filter (s: s.id == p.id || lib.hasPrefix "${p.id}/" s.id) r.scopes)
    ) (lib.filter (s: s.name == name && lib.elem s.kind places) r.scopes);
  noPlace =
    r: name:
    unknown "machine or home" name (map (s: s.name) (lib.filter (s: lib.elem s.kind places) r.scopes));
  # an edge origin is "aspect <n>", or "aspect <n>#<i>" when several files give the element
  aspectOf = e: lib.head (lib.splitString "#" (lib.removePrefix "aspect " e.origin));
in
{
  yen.queries = {
    aspectsOn =
      { name, result }:
      let
        ids = under result name;
      in
      if ids == [ ] then noPlace result name else lib.genAttrs ids (activeAt result);
    # shortcut: a text match over the aspect's files, so every aspect of a matching file is listed; upgrade when yen
    # records element origins inside module values.
    whoInstalls =
      { pkg, result }:
      let
        line = l: builtins.match ".*[.]${lib.escapeRegex pkg}([^a-zA-Z0-9_-].*)?" l != null;
        names = f: lib.hasPrefix "/" f && lib.any line (lib.splitString "\n" (builtins.readFile f)); # files only, not inline modules
        hits = lib.filter (n: lib.any names result.schema.aspects.${n}.files) (
          lib.attrNames result.schema.aspects
        );
      in
      lib.genAttrs hits (n: lib.filter (id: result.active.${n}.${id}) (lib.attrNames result.active.${n}));
    unfreeOn =
      { name, result }:
      let
        ids = under result name;
      in
      if ids == [ ] then
        noPlace result name
      else
        map
          (e: {
            aspect = aspectOf e;
            inherit (e) to;
          })
          (
            lib.filter (
              e: e.sink == "unfree" && lib.hasPrefix "aspect " e.origin && lib.elem e.to ids
            ) result.graph.edges
          );
    portsOf =
      { name, result }:
      let
        ids = under result name;
      in
      if ids == [ ] then
        noPlace result name
      else
        lib.concatMap (
          id: lib.concatMap (e: map (p: p // { at = id; }) e.value) (result.reduced.ports.${id} or [ ])
        ) ids;
    featuresOf =
      { vim, result }:
      if !(yen.vim ? ${vim}) then
        unknown "vim profile" vim (lib.attrNames yen.vim)
      else
        {
          inherit (yen.vim.${vim})
            features
            theme
            gui
            aliases
            ;
          aspects = lib.unique (
            map (e: lib.removePrefix "aspect " e.origin) (
              lib.filter (
                e: e.sink == "nvf" && lib.hasSuffix "/system:x86_64-linux/vim:${vim}" e.to
              ) result.graph.edges
            )
          );
        };
    inputsOf =
      { aspect, result }:
      if !(yen.aspects ? ${aspect}) then
        unknown "aspect" aspect (lib.attrNames result.active)
      else
        let
          f = yen.aspects.${aspect}.flake-file or { };
        in
        if lib.isAttrs f then f.inputs or { } else { };
  };
}
