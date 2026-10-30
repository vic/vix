# fleet ir (a fn of yen and lib): nodes + edges of the structure views, from `yen.lib.graph`, the kinds and the schema.
# A node is { id; label; kind; group }, an edge { from; to; label; live }. `_readme-map.nix` renders each view.
{ yen, lib }:
let
  inherit (yen.lib.batteries) mermaid;
  g = yen.lib.graph;
  byId = lib.listToAttrs (map (s: lib.nameValuePair s.id s) g.scopes);
  parentOf = id: lib.concatStringsSep "/" (lib.init (lib.splitString "/" id));
  root = lib.findFirst (s: s.kind == "fleet") null g.scopes;
  under = p: k: lib.filter (s: s.kind == k && parentOf s.id == p.id) g.scopes;
  places = [
    "host"
    "mac"
    "guest"
    "home"
  ];
  # a machine or home sits in the system it builds for; a user sits with its place
  groupOf =
    s:
    if lib.elem s.kind places then
      "${root.id}/system:${yen.${s.kind}.${s.name}.system.name}"
    else if
      s.kind == "user" && byId ? ${parentOf s.id} && lib.elem byId.${parentOf s.id}.kind places
    then
      groupOf byId.${parentOf s.id}
    else
      null;
in
import ./_fleet-gates.nix { inherit yen lib; }
// {
  fleetMap = mermaid.scopes {
    keep =
      s:
      !lib.elem s.kind [
        "vim"
        "env"
      ];
    label =
      s:
      if s.kind == "system" then
        "${s.name} · ${toString (lib.length (under s "vim"))} vim, ${toString (lib.length (under s "env"))} env"
      else
        s.name;
    group = groupOf;
    # grouped machines and homes need no edge from the fleet; users and guests keep the edge from their parent
    edge =
      s:
      groupOf s == null
      || lib.elem s.kind [
        "user"
        "guest"
      ];
  } g;

  # solid = `spawns` (parent kind to child kind), dotted = a field that is a ref to another kind
  kindTree = mermaid.kinds yen.kinds;

  # dashed: a sink key that feeds another sink (label: the kind); solid: `out`, labelled with its receivers
  forwards = mermaid.sinks yen.lib;
}
