# Stored queries: named questions with typed parameters; an agent lists them (`queries`) and calls `ask name args`.
# A parameter that names a fleet thing is a ref: from JSON `{ kind = "host"; name = "frodo"; }`, or `{ aspect = "…"; }`.
# - aspectsOn { place }   the aspects active at a machine or home, and at each scope below it (its users), by scope id
# - whoInstalls { pkg }   aspects whose files name `<x>.pkg`, and the scopes where each is active
# - unfreeOn { place }    the aspects that allow an unfree package at a machine or home or at its users, and where
# - portsOf { place }     the ports (`ports` sink) of a machine or home and of its users, each with its receiver scope id
# - featuresOf { vim }    a vim profile's features, and the aspects that give it nvf modules (x86_64-linux)
# - inputsOf { aspect }   the flake inputs an aspect declares on the flake-file sink
{ yen, lib, ... }:
let
  # a machine or home: the places a query names
  place = yen.lib.oneOf [
    yen.kinds.host
    yen.kinds.mac
    yen.kinds.guest
    yen.kinds.home
  ];
  activeAt = r: id: lib.filter (n: r.active.${n}.${id}) (lib.attrNames r.active);
  # the ids of the place p and of each scope below it
  under =
    r: p:
    lib.concatMap (
      s: map (x: x.id) (lib.filter (x: x.id == s.id || lib.hasPrefix "${s.id}/" x.id) r.scopes)
    ) (lib.filter (yen.lib.same p) r.scopes);
  # an edge origin is "aspect <n>", or "aspect <n>#<i>" when several files give the element
  aspectOf = e: lib.head (lib.splitString "#" (lib.removePrefix "aspect " e.origin));
  # the ports of the place p and of its users, each with the id of the scope that receives it
  portsOf =
    result: p:
    lib.concatMap (
      id: lib.concatMap (e: map (x: x // { at = id; }) e.value) (result.reduced.ports.${id} or [ ])
    ) (under result p);
  # shortcut: a text match over the aspect's files, so every aspect of a matching file is listed; upgrade when yen
  # records element origins inside module values.
  installs =
    pkg: f:
    lib.hasPrefix "/" f
    && lib.any (l: builtins.match ".*[.]${lib.escapeRegex pkg}([^a-zA-Z0-9_-].*)?" l != null) (
      lib.splitString "\n" (builtins.readFile f)
    ); # files only, not inline modules
in
{
  yen.helpers.portsOf = portsOf;
  yen.queries = {
    aspectsOn = {
      params.place = place;
      answer = { result, place }: lib.genAttrs (under result place) (activeAt result);
    };
    whoInstalls = {
      params.pkg = yen.lib.str;
      answer =
        { result, pkg }:
        lib.genAttrs (lib.filter (n: lib.any (installs pkg) result.schema.aspects.${n}.files) (
          lib.attrNames result.schema.aspects
        )) (n: lib.filter (id: result.active.${n}.${id}) (lib.attrNames result.active.${n}));
    };
    unfreeOn = {
      params.place = place;
      answer =
        { result, place }:
        map
          (e: {
            aspect = aspectOf e;
            inherit (e) to;
          })
          (
            lib.filter (
              e: e.sink == "unfree" && lib.hasPrefix "aspect " e.origin && lib.elem e.to (under result place)
            ) result.graph.edges
          );
    };
    portsOf = {
      params.place = place;
      answer = { result, place }: portsOf result place;
    };
    featuresOf = {
      params.vim = yen.kinds.vim;
      answer =
        { result, vim }:
        {
          inherit (result.data.vim.${vim.name})
            features
            theme
            gui
            aliases
            ;
          aspects = lib.unique (
            map (e: lib.removePrefix "aspect " e.origin) (
              lib.filter (
                e: e.sink == "nvf" && lib.hasSuffix "/system:x86_64-linux/vim:${vim.name}" e.to
              ) result.graph.edges
            )
          );
        };
    };
    inputsOf = {
      params.aspect = yen.lib.aspect;
      answer =
        { aspect, ... }:
        let
          f = yen.aspects.${aspect.__aspect}.flake-file or { };
        in
        if lib.isAttrs f then f.inputs or { } else { };
    };
  };
}
