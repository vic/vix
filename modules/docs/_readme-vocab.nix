# readme vocabulary (a fn of yen, lib and vocab): markdown tables rendered from live yen names, each checked against docs/_vocabulary.nix.
{
  yen,
  lib,
  vocab,
}:
let
  schema = yen.lib.schema;
  # one row of cells per name, under a header row
  table =
    head: cells: names:
    yen.lib.batteries.docs.table head (map cells names);
  code = n: "`${n}`";
  codes = xs: lib.concatMapStringsSep ", " code (lib.sort (a: b: a < b) (lib.unique xs));
  instances =
    k:
    let
      ns = lib.attrNames (yen.${k} or { });
    in
    if ns == [ ] then "- (abstract)" else lib.concatStringsSep ", " ns;
  # every (kind, sink) declaration, from the schema: reduce name, the sinks it feeds, `out`, a sink `at`
  decls = lib.concatLists (
    lib.mapAttrsToList (
      k: d:
      lib.mapAttrsToList (
        n: s:
        s
        // {
          kind = k;
          name = n;
        }
      ) d.sinks
    ) schema.kinds
  );
  on = n: lib.filter (d: d.name == n) decls;
  sinkCells = n: [
    (code n)
    (codes (map (d: d.kind) (on n)))
    (codes (map (d: d.reduce) (on n)))
    (codes (lib.concatMap (d: d.feeds) (on n))) # yen cffd8764: `out` is in feeds
    vocab.sinks.${n}
  ];
  live = what: lib.filter (n: yen.aspects ? ${n}) (lib.attrNames vocab.${what}); # aspects: stale lines only
  profiles =
    map (t: [
      (code t)
      vocab.tiers.${t}
    ]) (live "tiers")
    ++ map (r: [
      "role `${r}`"
      vocab.roles.${r}
    ]) (live "roles");
  inactive = lib.attrNames (lib.filterAttrs (_: a: a.activeAt == 0) schema.aspects);
in
''
  ### Kinds: one scope per instance when some `spawns` reaches the kind

  ${table [ "kind" "what it is" "instances (`yen.<kind>.<name>`)" ] (k: [
    (code k)
    vocab.kinds.${k}
    (instances k)
  ]) (lib.attrNames yen.kinds)}

  ### Sinks: where an aspect key sends its element

  An element goes to the nearest ancestor-or-self scope that has the sink. A sink key that names another sink forwards the reduced value to it.

  ${table [ "sink" "on" "reduce" "forwards to" "what" ] sinkCells (
    lib.unique (map (d: d.name) decls)
  )}

  ### vic profiles: tiers gate features (`at = yen.aspects.vic-<tier>`); roles come from facts or host files

  ${table [ "name" "active" ] (p: p) profiles}

  ${toString (lib.length (lib.attrNames yen.aspects))} aspects live under `modules/`; `yen.aspects.<name>` each.
  Active nowhere (empty `at`, or a marker no scope matches): ${codes inactive}.
''
