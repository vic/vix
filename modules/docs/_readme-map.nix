# readme map (a fn of ir): mermaid diagrams rendered from the fleet ir (docs/_fleet-ir.nix), one thin emitter for every view.
{ ir }:
let
  inherit (builtins)
    any
    concatMap
    concatStringsSep
    filter
    ;
  q = l: ''"${l}"'';
  shape = {
    mac = l: "(${q l})";
    guest = l: "[[${q l}]]";
    home = l: "[/${q l}/]";
    user = l: "((${q l}))";
    receiver = l: "(${q l})";
    output = l: "(${q l})";
  };
  box = n: n.id + (shape.${n.kind} or (l: "[${q l}]")) n.label;
  # a node other nodes name as their group renders as a subgraph around them
  mermaid =
    dir: view:
    let
      inside = g: filter (n: n.group == g.id) view.nodes;
      node =
        n:
        if any (m: m.group == n.id) view.nodes then
          [ "  subgraph ${n.id} [${q n.label}]" ] ++ map (m: "    ${box m}") (inside n) ++ [ "  end" ]
        else
          [ "  ${box n}" ];
      arrow = x: if x.live or true then "-->" else "-.->";
      edge = x: "  ${x.from} ${arrow x}${if x.label == "" then "" else "|${q x.label}|"} ${x.to}";
    in
    concatStringsSep "\n" (
      [
        "```mermaid"
        "flowchart ${dir}"
      ]
      ++ concatMap node (filter (n: n.group == null) view.nodes)
      ++ map edge view.edges
      ++ [ "```" ]
    );
in
{
  inherit mermaid;
  scopes = ''
    ## Fleet map

    Generated from live Ren instances (`ren.host`, `ren.mac`, `ren.guest`, `ren.home`). JSON: `nix build .#fleet-ir`.

    Scope tree: `[host]` `(mac)` `[[guest]]` `[/home/]` `((user))`, grouped by system. Each machine spawns its own `vic` scope; drawn once.

    ${mermaid "LR" ir.scopes}
  '';
  more = ''
    **Channels**: emitter to receiver, one edge per `ren.channels` name.

    ${mermaid "LR" ir.channels}

    **Class forwarding**: solid edges carry live instance names, dashed edges are static.

    ${mermaid "LR" ir.classes}
  '';
}
