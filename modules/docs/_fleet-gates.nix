# fleet gates (part of docs/_fleet-ir.nix): the routing table, the kind-level routing graph and the gate lattice, read from `yen.lib.graph` and each `at`.
{ yen, lib }:
let
  g = yen.lib.graph;
  sorted = xs: lib.sort (a: b: a < b) (lib.unique xs);
  kindOf = lib.listToAttrs (map (s: lib.nameValuePair s.id s.kind) g.scopes);
  # `at` as refs: aspect refs, kinds, instances and fact tests, each with the operators above it
  walk =
    op: p:
    if lib.isFunction p then
      [
        {
          inherit op;
          ref = "fact";
        }
      ]
    else if lib.isList p then
      lib.concatMap (walk op) p
    else if p ? __all then
      lib.concatMap (walk op) p.__all
    else if p ? __not then
      walk (op ++ [ "not" ]) p.__not
    else if p ? __within then
      walk (op ++ [ "within" ]) p.__within
    else if p ? __has then
      walk (op ++ [ "has" ]) p.__has
    else if p ? __kind then
      [
        {
          inherit op;
          ref = "kind ${p.__kind}";
        }
      ]
    else if p ? __aspect then
      [
        {
          inherit op;
          ref = p.__aspect;
          aspect = true;
        }
      ]
    else if p ? kind && p ? name then
      [
        {
          inherit op;
          ref = "${p.kind}:${p.name}";
        }
      ]
    else
      [
        {
          inherit op;
          ref = "fact";
        }
      ];
  refsOf = n: walk [ ] (yen.aspects.${n}.at or [ ]);
  gated = lib.concatMap (
    n:
    map (r: {
      from = r.ref;
      to = n;
    }) (lib.filter (r: r.aspect or false) (refsOf n))
  ) (lib.attrNames yen.aspects);
  gates = sorted (map (x: x.from) gated);
  others = n: lib.filter (r: !(r.aspect or false) && r.ref != "fact") (refsOf n);
  fromAspects = lib.filter (e: lib.hasPrefix "aspect " e.origin) g.edges;
  # edges "x>y" counted: [ { from; to; label; } ] with the element count as label
  counted =
    f: from: to:
    lib.mapAttrsToList (
      k: v:
      let
        ab = lib.splitString ">" k;
      in
      {
        from = from (lib.head ab);
        to = to (lib.last ab);
        label = toString (lib.length v);
      }
    ) (lib.groupBy f fromAspects);
  routedSinks = sorted (map (e: e.sink) fromAspects);
  routedKinds = sorted (map (e: kindOf.${e.from}) fromAspects ++ map (e: kindOf.${e.to}) fromAspects);
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
    ) routedSinks
  );

  # kind level only: the kind of the giving scope -> sink -> the kind of the receiver, edges labelled by element count
  routingKinds = {
    nodes =
      map (k: {
        id = "k:${k}";
        label = k;
        kind = k;
      }) routedKinds
      ++ map (s: {
        id = "s:${s}";
        label = s;
        kind = "sink";
      }) routedSinks;
    edges =
      counted (e: "${kindOf.${e.from}}>${e.sink}") (k: "k:${k}") (s: "s:${s}")
      ++ counted (e: "${e.sink}>${kindOf.${e.to}}") (s: "s:${s}") (k: "k:${k}");
  };

  # the gates (aspects other aspects name in `at`) and what each gate's own `at` reads; dashed under a `not`
  lattice = {
    nodes =
      map (n: {
        id = "a:${n}";
        label = "${n} · ${toString (lib.length (lib.filter (x: x.from == n) gated))} gated";
        kind = "aspect";
      }) gates
      ++ map (r: {
        id = "r:${r}";
        label = r;
        kind = "ref";
      }) (sorted (lib.concatMap (n: map (r: r.ref) (others n)) gates))
      ++ map (n: {
        id = "f:${n}";
        label = "fact test";
        kind = "ref";
      }) (lib.filter (n: lib.any (r: r.ref == "fact") (refsOf n)) gates);
    edges = lib.unique (
      lib.concatMap (
        n:
        map (r: {
          from =
            if r.aspect or false then
              "a:${r.ref}"
            else if r.ref == "fact" then
              "f:${n}"
            else
              "r:${r.ref}";
          to = "a:${n}";
          label = lib.concatStringsSep " " r.op;
          live = !lib.elem "not" r.op;
        }) (refsOf n)
      ) gates
    );
  };
}
