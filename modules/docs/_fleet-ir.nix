# fleet ir (a fn of ren and chans): nodes + edges of three views (scopes, channels, classes) from live Ren data; `_readme-map.nix` renders each.
{
  lib,
  ren,
  chans,
}:
let
  inherit (builtins)
    attrNames
    attrValues
    concatMap
    elem
    filter
    match
    replaceStrings
    throw
    ;
  id = replaceStrings [ "-" "." "@" " " "/" ] [ "_" "_" "_" "_" "_" ];
  node = kind: label: group: {
    id = id "${kind}-${label}";
    inherit kind label group;
  };
  edge = from: to: label: { inherit from to label; };
  # one node per label (a label two edges share is drawn once), ordered by id
  uniq = ns: builtins.sort (a: b: a.id < b.id) (lib.dedupByKey (n: n.id) ns);
  hosts = attrValues ren.host;
  macs = attrValues ren.mac;
  guests = attrValues ren.guest;
  homes = attrValues ren.home;
  fleets = attrValues ren.fleet;
  sys = i: id "system-${i.system.name}";
  used = filter (s: elem (sys { system = s; }) (map sys (hosts ++ macs ++ guests ++ homes))) (
    attrValues ren.system
  );
  users =
    kind: i: map (u: edge (id "${kind}-${i.name}") (id "user-${u.name}") "") (i.users or [ i.user ]);
  # channels: guarded like the vocabulary tables, one line per live channel
  ends = c: match "(.*) -> (.*)" chans.${c};
  bad =
    filter (c: !(chans ? ${c})) (attrNames ren.channels)
    ++ filter (c: !(ren.channels ? ${c}) || ends c == null) (attrNames chans);
  pair =
    c:
    if bad == [ ] then
      ends c
    else
      throw "docs/_fleet-channels.nix: missing, stale or malformed [${toString bad}]";
  cs = attrNames chans;
in
{
  scopes = {
    nodes =
      map (f: node "fleet" f.name null) fleets
      ++ map (s: node "system" s.name null) used
      ++ map (h: node "host" h.name (sys h)) hosts
      ++ map (m: node "mac" m.name (sys m)) macs
      ++ map (g: node "guest" g.name (sys g)) guests
      ++ map (h: node "home" h.name (sys h)) homes
      ++ map (u: node "user" u.name null) (attrValues ren.user);
    # Ren roots: the fleet lists systems, hosts, macs and homes below it; edges go to each system group
    edges =
      concatMap (f: map (s: edge (id "fleet-${f.name}") (id "system-${s.name}") "") used) fleets
      ++ map (g: edge (id "host-${g.on.name}") (id "guest-${g.name}") "guest") guests
      ++ concatMap (users "host") hosts
      ++ concatMap (users "mac") macs
      ++ concatMap (users "guest") guests
      ++ concatMap (users "home") homes;
  };
  channels = {
    nodes = uniq (
      concatMap (c: [
        (node "emitter" (builtins.elemAt (pair c) 0) null)
        (node "receiver" (builtins.elemAt (pair c) 1) null)
      ]) cs
    );
    edges = map (
      c: edge (id "emitter-${builtins.elemAt (pair c) 0}") (id "receiver-${builtins.elemAt (pair c) 1}") c
    ) cs;
  };
  classes = import ./_fleet-classes.nix {
    inherit ren id uniq;
    inherit
      hosts
      macs
      guests
      homes
      ;
  };
}
