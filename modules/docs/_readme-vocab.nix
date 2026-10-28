# readme vocabulary (a fn of sven, lib and vocab): markdown tables rendered from live sven names, each checked against docs/_vocabulary.nix.
{
  sven,
  lib,
  vocab,
}:
let
  described = import ./_described.nix "_vocabulary.nix";
  schema = sven.lib.schema;
  row = cells: "| ${lib.concatStringsSep " | " cells} |";
  # one row of cells per name, under a header row
  table =
    head: cells: names:
    lib.concatStringsSep "\n" (
      map row (
        [
          head
          (map (_: "---") head)
        ]
        ++ map cells names
      )
    );
  code = n: "`${n}`";
  codes = xs: lib.concatMapStringsSep ", " code (lib.sort (a: b: a < b) (lib.unique xs));
  instances =
    k:
    let
      ns = lib.attrNames (sven.${k} or { });
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
    (codes (lib.concatMap (d: d.feeds ++ lib.optional d.out "out") (on n)))
    vocab.sinks.${n}
  ];
  live = what: lib.filter (n: sven.aspects ? ${n}) (lib.attrNames vocab.${what}); # aspects: stale lines only
  profiles =
    map (t: [
      (code t)
      vocab.tiers.${t}
    ]) (described "tiers" (live "tiers") vocab.tiers)
    ++ map (r: [
      "role `${r}`"
      vocab.roles.${r}
    ]) (described "roles" (live "roles") vocab.roles);
  inactive = lib.attrNames (lib.filterAttrs (_: a: a.activeAt == 0) schema.aspects);
in
''
  ### Kinds: one scope per instance when some `spawns` reaches the kind

  ${table [ "kind" "what it is" "instances (`sven.<kind>.<name>`)" ] (k: [
    (code k)
    vocab.kinds.${k}
    (instances k)
  ]) (described "kinds" (lib.attrNames sven.kinds) vocab.kinds)}

  ### Sinks: where an aspect key sends its element

  An element goes to the nearest ancestor-or-self scope that has the sink. A sink key that names another sink forwards the reduced value to it.

  ${table [ "sink" "on" "reduce" "forwards to" "what" ] sinkCells (
    described "sinks" (lib.unique (map (d: d.name) decls)) vocab.sinks
  )}

  ### vic profiles: tiers gate features (`at = sven.aspects.vic-<tier>`); roles come from facts or host files

  ${table [ "name" "active" ] (p: p) profiles}

  ${toString (lib.length (lib.attrNames sven.aspects))} aspects live under `modules/`; `sven.aspects.<name>` each.
  Active nowhere (empty `at`, or a marker no scope matches): ${codes inactive}.
''
