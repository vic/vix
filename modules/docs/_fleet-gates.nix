# fleet gates (part of docs/_fleet-ir.nix): the routing table, the kind-level routing graph and the gate lattice, read from `yen.lib.graph` and each `at`.
{ yen, lib }:
let
  inherit (yen.lib.batteries) mermaid;
  g = yen.lib.graph;
  sorted = xs: lib.sort (a: b: a < b) (lib.unique xs);
  kindOf = lib.listToAttrs (map (s: lib.nameValuePair s.id s.kind) g.scopes);
  fromAspects = lib.filter (e: lib.hasPrefix "aspect " e.origin) g.edges;
in
{
  # one row per sink: the aspects that give to it, the kinds that receive it, the routed elements; most used first
  routingTable = lib.sort (a: b: a.elements > b.elements) (
    map (
      s:
      let
        es = lib.filter (e: e.sink == s) fromAspects;
      in
      {
        sink = s;
        aspects = lib.length (lib.unique (map (e: e.origin) es));
        receivedAt = sorted (map (e: kindOf.${e.to}) es);
        elements = lib.length es;
      }
    ) (sorted (map (e: e.sink) fromAspects))
  );

  # kind level only: the kind of the giving scope -> sink -> the kind of the receiver, edges labelled by element count
  routingKinds = mermaid.routing g;

  # the gates (aspects other aspects name in `at`) and what each gate's own `at` reads; dashed under a `not`
  lattice = mermaid.gates yen.aspects;
}
