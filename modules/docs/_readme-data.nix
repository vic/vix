# readme data (a fn of yen, lib, mermaid and the ci-jobs value): machine-side tables and diagrams of vix's data and routed elements.
{
  yen,
  lib,
  mermaid,
  ciJobs,
}:
let
  g = yen.lib.graph;
  sorted = xs: lib.sort (a: b: a < b) (lib.unique xs);
  code = xs: lib.concatMapStringsSep ", " (x: "`${x}`") (sorted xs);
  row = cells: "| ${lib.concatStringsSep " | " cells} |";
  table =
    head: rows:
    lib.concatStringsSep "\n" (
      map row (
        [
          head
          (map (_: "---") head)
        ]
        ++ rows
      )
    );
  aspectOf = e: lib.removePrefix "aspect " e.origin;

  # aspects giving elements at a place or below it (its users)
  places = lib.filter (
    s:
    lib.elem s.kind [
      "host"
      "mac"
      "guest"
      "home"
    ]
  ) g.scopes;
  at = lib.listToAttrs (
    map (
      p:
      lib.nameValuePair p.id (
        sorted (
          map aspectOf (
            lib.filter (
              e: lib.hasPrefix "aspect " e.origin && (e.from == p.id || lib.hasPrefix "${p.id}/" e.from)
            ) g.edges
          )
        )
      )
    ) places
  );
  matrix = table ([ "aspect" ] ++ map (p: p.name) places) (
    map (a: [ "`${a}`" ] ++ map (p: if lib.elem a at.${p.id} then "x" else "") places) (
      sorted (lib.concatLists (lib.attrValues at))
    )
  );

  inputs = lib.filterAttrs (_: v: v != [ ]) (
    lib.mapAttrs (
      _: a:
      let
        f = a.flake-file or null;
      in
      if lib.isAttrs f && f ? inputs then lib.attrNames f.inputs else [ ]
    ) yen.aspects
  );

  ci = table [ "runner" "system" "jobs" "may fail" ] (
    lib.mapAttrsToList (r: js: [
      "`${r}`"
      (code (map (j: j.system) js))
      (code (map (j: j.name) js))
      (code (map (j: j.name) (lib.filter (j: j.allowFailure) js)))
    ]) (lib.groupBy (j: if j.runner == null then "none" else j.runner) (lib.attrValues ciJobs))
  );

  # ssh: by Host match name, each host to every hop of its proxyJump (user@ dropped), as topology/ssh-hosts.nix
  nameOf = n: h: if h.host != null then h.host else n;
  hosts = lib.mapAttrs' (n: h: lib.nameValuePair (nameOf n h) h) yen.ssh-host;
  jumps = lib.mapAttrs (
    _: h:
    lib.optionals (h.proxyJump != null) (
      map (j: lib.last (lib.splitString "@" j)) (lib.splitString "," h.proxyJump)
    )
  ) hosts;
  ssh = {
    nodes = map (n: {
      id = "ssh:${n}";
      label = if (hosts.${n}.hostname or null) == null then n else "${n} · ${hosts.${n}.hostname}";
      kind = if hosts ? ${n} then "host" else "output";
    }) (yen.lib.graphs.nodesOf jumps);
    edges = lib.concatLists (
      lib.mapAttrsToList (
        n:
        map (t: {
          from = "ssh:${n}";
          to = "ssh:${t}";
          label = "proxyJump";
        })
      ) jumps
    );
  };
  # a jump cycle never connects: the ssh-jumps aspect gives an error record for each
  jumpCycles = map (lib.concatStringsSep " -> ") (yen.lib.graphs.sccs jumps);
in
''
  ## Fleet data

  <details><summary>Aspects by machine and home (an aspect that gave an element there or to a user below)</summary>

  ${matrix}

  </details>

  **Flake inputs by aspect** (the `flake-file` sink writes flake.nix from them):

  ${table [ "aspect" "inputs" ] (
    lib.mapAttrsToList (a: is: [
      "`${a}`"
      (code is)
    ]) inputs
  )}

  **CI jobs by runner** (`nix eval --json .#ci.matrix`; ci.yml also runs one job per `checks.<sys>.<name>`):

  ${ci}

  **ssh hosts and jumps** (`yen.ssh-host`, by Host match name). Jump cycles: ${
    if jumpCycles == [ ] then "none" else code jumpCycles
  }.

  ${mermaid ssh}
''
