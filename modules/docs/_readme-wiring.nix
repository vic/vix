# readme wiring (a fn of sven, lib, mermaid and the ci-jobs value): ports per scope, CI runners per system, flake input follows.
{
  sven,
  lib,
  mermaid,
  ciJobs,
}:
let
  g = sven.lib.graph;
  G = sven.lib.graphs;
  sorted = xs: lib.sort (a: b: a < b) (lib.unique xs);
  code = xs: lib.concatMapStringsSep ", " (x: "`${x}`") (sorted xs);
  kindOf = lib.listToAttrs (map (s: lib.nameValuePair s.id s.kind) g.scopes);
  # an edge origin is "aspect <n>", or "aspect <n>#<i>" when several files give the element
  aspectOf = e: lib.head (lib.splitString "#" (lib.removePrefix "aspect " e.origin));
  # "vic@frodo" for a user scope, else the scope name
  labelOf =
    id:
    let
      ks = map (lib.splitString ":") (lib.splitString "/" id);
      n = lib.length ks;
    in
    if lib.head (lib.last ks) == "user" then
      "${lib.last (lib.last ks)}@${lib.last (lib.elemAt ks (n - 2))}"
    else
      lib.last (lib.last ks);

  # shortcut: reads each aspect's declared `ports` list (a function element is skipped), as unique-port does;
  # upgrade when the docs can read `reduced`
  portsOf =
    n:
    let
      v = sven.aspects.${n}.ports or [ ];
    in
    if lib.isList v then v else [ ];
  given = lib.filter (e: e.sink == "ports" && lib.hasPrefix "aspect " e.origin) g.edges;
  portId = p: "port:${toString p.port}:${p.what}";
  ports = {
    nodes =
      map (id: {
        inherit id;
        label = labelOf id;
        kind = kindOf.${id};
      }) (sorted (map (e: e.to) given))
      ++ lib.unique (
        lib.concatMap (
          e:
          map (p: {
            id = portId p;
            label = ":${toString p.port} ${p.what} (${aspectOf e})";
            kind = "sink";
          }) (portsOf (aspectOf e))
        ) given
      );
    edges = lib.unique (
      lib.concatMap (
        e:
        map (p: {
          from = e.to;
          to = portId p;
        }) (portsOf (aspectOf e))
      ) given
    );
  };
  # aspects with ports that route nowhere (empty `at`, or no scope matches)
  idle = lib.filter (n: sven.aspects.${n} ? ports && !lib.any (e: aspectOf e == n) given) (
    lib.attrNames sven.aspects
  );

  # CI: each system's runner label is derived from the one machine on it with `ghRunner`; `ciBroken` lets a job fail
  machines = lib.concatMap (k: lib.attrValues (sven.${k} or { })) [
    "host"
    "guest"
    "mac"
    "home"
  ];
  marked = lib.filter (m: m.ghRunner != null || m.ciBroken != null) machines;
  jobsOn = s: lib.filter (j: j.system == s) (lib.attrValues ciJobs);
  ci = {
    nodes =
      map (s: {
        id = "sys:${s}";
        label = "${s} · runs-on ${
          if sven.system.${s}.runner == null then "none" else sven.system.${s}.runner
        } · ${toString (lib.length (jobsOn s))} jobs";
        kind = "system";
      }) (lib.attrNames sven.system)
      ++ map (m: {
        id = "m:${m.kind}:${m.name}";
        label =
          if m.ghRunner != null then
            "${m.name} · ghRunner ${m.ghRunner}"
          else
            "${m.name} · ciBroken ${m.ciBroken}";
        inherit (m) kind;
      }) marked;
    edges = map (m: {
      from = "m:${m.kind}:${m.name}";
      to = "sys:${m.system.name}";
      label = if m.ghRunner != null then "runner" else "may fail";
      live = m.ghRunner != null;
    }) marked;
  };

  # flake inputs of the active aspects: each input to the inputs it (or one of its inputs) follows
  inputsOf =
    n:
    let
      f = sven.aspects.${n}.flake-file or null;
    in
    if lib.isAttrs f && lib.isAttrs (f.inputs or null) then f.inputs else { };
  inputs = lib.filterAttrs (_: lib.isAttrs) (
    lib.foldl' (a: n: a // inputsOf n) { } (
      lib.filter (n: sven.lib.schema.aspects.${n}.activeAt > 0) (lib.attrNames sven.aspects)
    )
  );
  follows =
    i:
    lib.optional (lib.isString (i.follows or null) && i.follows != "") (
      lib.head (lib.splitString "/" i.follows)
    )
    ++ lib.concatMap follows (lib.attrValues (lib.filterAttrs (_: lib.isAttrs) (i.inputs or { })));
  succ = lib.filterAttrs (_: ts: ts != [ ]) (lib.mapAttrs (_: follows) inputs);
  by = G.transpose succ;
  follow = {
    nodes = map (n: {
      id = "in:${n}";
      label = "${n}${lib.optionalString (by.${n} != [ ]) " · ${toString (lib.length by.${n})} follow"}";
      kind = if inputs ? ${n} then "input" else "ref";
    }) (G.nodesOf succ);
    edges = lib.concatLists (
      lib.mapAttrsToList (
        n:
        map (t: {
          from = "in:${n}";
          to = "in:${t}";
        })
      ) succ
    );
  };
  undeclared = lib.subtractLists (lib.attrNames inputs) (G.nodesOf succ);
in
''
  **Ports per scope** (the `ports` sink; `ask "portsOf"`, `ask "freePort"`). Declared, routed nowhere: ${
    if idle == [ ] then "none" else code idle
  }.

  ${mermaid ports}

  **CI runners per system**: the runner label of a system comes from the one machine on it with `ghRunner`
  (0 or 2+ is an error record); a dashed edge is a machine whose job may fail (`ciBroken`).

  ${mermaid ci}

  <details><summary>Flake input follows (${toString (lib.length (lib.attrNames succ))} of ${toString (lib.length (lib.attrNames inputs))} inputs follow another)</summary>

  Follows targets flake.nix does not declare (the follows-declared invariant): ${
    if undeclared == [ ] then "none" else code undeclared
  }.

  ${mermaid follow}

  </details>
''
