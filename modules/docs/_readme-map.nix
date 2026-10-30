# readme map (a fn of lib, yen and ir): one fenced mermaid emitter for every view, and the structure diagrams of docs/_fleet-ir.nix.
{
  lib,
  yen,
  ir,
}:
let
  inherit (yen.lib.batteries.mermaid) flowchart shapes;
  # a node other nodes name as their group renders as a subgraph around them
  mermaid =
    view:
    "```mermaid\n"
    + flowchart {
      shapes = {
        mac = shapes.round;
        guest = shapes.subroutine;
        home = shapes.parallelogram;
        user = shapes.circle;
        sink = shapes.round;
        output = shapes.cylinder;
        ref = shapes.hexagon;
        secret = shapes.hexagon;
      };
    } view
    + "\n```";
  # one markdown row per sink, most routed elements first
  routingTable =
    rows:
    yen.lib.batteries.docs.table [ "Sink" "Given by (aspects)" "Received at" "Elements" ] (
      map (r: [
        "`${r.sink}`"
        (toString r.aspects)
        (lib.concatStringsSep ", " r.receivedAt)
        (toString r.elements)
      ]) rows
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
