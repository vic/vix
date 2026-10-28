# fleet ir (a fn of sven and lib): nodes + edges of the structure views, from `sven.lib.graph` and kind and sink declarations.
# A node is { id; label; kind; group }, an edge { from; to; label; live }. `_readme-map.nix` renders each view.
{ sven, lib }:
let
  g = sven.lib.graph;
  sorted = xs: lib.sort (a: b: a < b) (lib.unique xs);
  names = v: if lib.isAttrs v then lib.attrNames v else [ ];
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
      "${root.id}/system:${sven.${s.kind}.${s.name}.system.name}"
    else if
      s.kind == "user" && byId ? ${parentOf s.id} && lib.elem byId.${parentOf s.id}.kind places
    then
      groupOf byId.${parentOf s.id}
    else
      null;
  drawn = lib.filter (
    s:
    !lib.elem s.kind [
      "vim"
      "env"
    ]
  ) g.scopes;
  # the sink a key names: everything in a sink declaration but these is a forward
  meta = [
    "reduce"
    "of"
    "at"
    "out"
  ];
  sinkDecls = lib.concatLists (
    lib.mapAttrsToList (
      k: d:
      lib.mapAttrsToList (n: v: {
        kind = k;
        name = n;
        decl = if lib.isAttrs v then v else { };
      }) (d.sinks or { })
    ) sven.kinds
  );
  receiversOf =
    sink:
    sorted (map (e: lib.last (lib.splitString ":" e.to)) (lib.filter (e: e.sink == sink) g.edges));
in
import ./_fleet-gates.nix { inherit sven lib; }
// {
  fleetMap = {
    nodes = map (s: {
      inherit (s) id kind;
      label =
        if s.kind == "system" then
          "${s.name} · ${toString (lib.length (under s "vim"))} vim, ${toString (lib.length (under s "env"))} env"
        else
          s.name;
      group = groupOf s;
    }) drawn;
    # grouped machines and homes need no edge from the fleet; users and guests keep the edge from their parent
    edges =
      map
        (s: {
          from = parentOf s.id;
          to = s.id;
        })
        (
          lib.filter (
            s:
            s.id != root.id && groupOf s == null
            || lib.elem s.kind [
              "user"
              "guest"
            ]
          ) drawn
        );
  };

  # solid = `spawns` (parent kind to child kind), dotted = a field that is a ref to another kind
  kindTree = {
    nodes = map (k: {
      id = "k:${k}";
      label = k;
      kind = "kind";
    }) (lib.attrNames sven.kinds);
    edges = lib.concatLists (
      lib.mapAttrsToList (
        k: d:
        map (c: {
          from = "k:${k}";
          to = "k:${c}";
        }) (names (d.spawns or { }))
        ++ lib.concatLists (
          lib.mapAttrsToList (
            f: t:
            lib.optional (lib.isAttrs t && t ? __kind) {
              from = "k:${k}";
              to = "k:${t.__kind}";
              label = f;
              live = false;
            }
          ) (d.fields or { })
        )
      ) sven.kinds
    );
  };

  # dashed: a sink key that feeds another sink (label: the kind); solid: `out`, labelled with its receivers
  forwards = {
    nodes =
      map
        (n: {
          id = "sink:${n}";
          label = n;
          kind = "sink";
        })
        (
          sorted (
            map (d: d.name) sinkDecls ++ lib.concatMap (d: lib.subtractLists meta (names d.decl)) sinkDecls
          )
        )
      ++ [
        {
          id = "flake";
          label = "flake outputs";
          kind = "output";
        }
      ];
    edges = lib.unique (
      lib.concatMap (
        d:
        map (t: {
          from = "sink:${d.name}";
          to = "sink:${t}";
          label = d.kind;
          live = false;
        }) (lib.subtractLists meta (names d.decl))
        ++ lib.optional (d.decl ? out) {
          from = "sink:${d.name}";
          to = "flake";
          label = lib.concatStringsSep ", " (lib.take 6 (receiversOf d.name));
        }
      ) sinkDecls
    );
  };
}
