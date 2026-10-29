# readme map (a fn of lib and ir): one thin mermaid emitter for every view, and the structure diagrams of docs/_fleet-ir.nix.
{ lib, ir }:
let
  # md5 ids: any label is safe, and the same scope gets the same id in every view
  node = id: "n${builtins.substring 0 10 (builtins.hashString "md5" id)}";
  q = l: ''"${lib.replaceStrings [ "\"" ] [ "'" ] l}"'';
  shape = {
    mac = l: "(${q l})";
    guest = l: "[[${q l}]]";
    home = l: "[/${q l}/]";
    user = l: "((${q l}))";
    sink = l: "(${q l})";
    output = l: "[(${q l})]";
    ref = l: "{{${q l}}}";
    secret = l: "{{${q l}}}";
  };
  box = n: node n.id + (shape.${n.kind} or (l: "[${q l}]")) n.label;
  # a node other nodes name as their group renders as a subgraph around them
  mermaid =
    view:
    let
      inside = p: lib.filter (n: (n.group or null) == p.id) view.nodes;
      isGroup = n: lib.any (m: (m.group or null) == n.id) view.nodes;
      draw =
        n:
        if isGroup n then
          [ "  subgraph ${node n.id} [${q n.label}]" ] ++ map (m: "    ${box m}") (inside n) ++ [ "  end" ]
        else
          [ "  ${box n}" ];
      edge =
        e:
        "  ${node e.from} ${if e.live or true then "-->" else "-.->"}${
            if (e.label or "") == "" then "" else "|${q e.label}|"
          } ${node e.to}";
    in
    lib.concatStringsSep "\n" (
      [
        "```mermaid"
        "flowchart LR"
      ]
      ++ lib.concatMap draw (lib.filter (n: (n.group or null) == null) view.nodes)
      ++ map edge view.edges
      ++ [ "```" ]
    );
  # one markdown row per sink, most routed elements first
  routingTable =
    rows:
    lib.concatStringsSep "\n" (
      [
        "| Sink | Given by (aspects) | Received at | Elements |"
        "|---|---|---|---|"
      ]
      ++ map (
        r:
        "| `${r.sink}` | ${toString r.aspects} | ${lib.concatStringsSep ", " r.receivedAt} | ${toString r.elements} |"
      ) rows
    );
in
{
  inherit mermaid;
  structure = ''
    ## Fleet map

    Generated from `yen.lib.graph`: every scope under its parent. Machines and homes sit in the system they build for.
    `[host]` `(mac)` `[[guest]]` `[/home/]` `((user))`. JSON of every view: `nix build .#fleet-ir`.

    ${mermaid ir.fleetMap}

    **Kind tree**: solid edges are `spawns`; dotted edges are fields that refer to another kind.

    ${mermaid ir.kindTree}

    **Sink forwarding**: a dashed edge is a sink key that feeds another sink (label: the kind that declares it).
    A solid edge is `out`, labelled with the receivers that build a flake output.

    ${mermaid ir.forwards}

    **Gates**: the aspects other aspects name in `at` (tiers and roles), and what each one's own `at` reads.
    A dashed edge is under a `not`. The count is the aspects that name the gate.

    ${mermaid ir.lattice}

    **Routing**: where aspect elements go, per sink. "Given by" counts the aspects that give to the sink;
    "Received at" is the kind of the scope that reduces it (the nearest ancestor-or-self with the sink).

    ${routingTable ir.routingTable}

    <details><summary>Routing by kind: giving kind, sink, receiving kind (edge label: elements)</summary>

    ${mermaid ir.routingKinds}

    </details>
  '';
}
