# readme capabilities (a fn of yen, lib, mermaid and the engine lib): counts, invariants, stored queries, MCP tools, library index.
# Nothing is listed by hand, so nothing goes missing.
{
  yen,
  lib,
  mermaid,
  engine,
}:
let
  g = yen.lib.graph;
  sorted = xs: lib.sort (a: b: a < b) (lib.unique xs);
  code = xs: lib.concatMapStringsSep ", " (x: "`${x}`") (sorted xs);
  names = v: if lib.isAttrs v then lib.attrNames v else [ ];
  kindOf = lib.listToAttrs (map (s: lib.nameValuePair s.id s.kind) g.scopes);
  # repo-relative: the same in the working tree and the store
  rel =
    f:
    let
      m = builtins.match ".*/(modules/.*)" f;
    in
    if m == null then baseNameOf f else lib.head m;
  files = path: lib.concatMapStringsSep ", " (f: "`${rel f}`") (yen.lib.declaredIn path);
  kindRow =
    k:
    let
      d = yen.kinds.${k};
    in
    "| `${k}` | ${code (names (d.fields or { }))} | ${code (names (d.spawns or { }))} | ${code (names (d.sinks or { }))} | ${
      toString (lib.length (lib.filter (s: s.kind == k) g.scopes))
    } |";
  sinkRow =
    k:
    let
      es = lib.filter (e: e.sink == k) g.edges;
    in
    "| `${k}` | ${code (map (e: kindOf.${e.from}) es)} | ${
      code (map (e: kindOf.${e.to}) es)
    } | ${toString (lib.length es)} |";
  queryRow =
    n:
    let
      fa = builtins.functionArgs yen.queries.${n};
      ps = lib.filter (a: a != "r") (lib.attrNames fa);
    in
    "| `${n}` | ${code (lib.filter (a: !fa.${a}) ps)} | ${code (lib.filter (a: fa.${a}) ps)} | ${
      files [
        "queries"
        n
      ]
    } |";
  mcpTools = sorted (
    lib.filter lib.isString (
      lib.flatten (
        map (l: builtins.match ".*\"name\":\"(yen_[a-z_]+)\".*" l) (
          lib.splitString "\n" (
            builtins.replaceStrings [ "{" ] [ "\n{" ] (builtins.readFile ../../mcp/yen-mcp.sh)
          )
        )
      )
    )
  );
  mcpView = {
    nodes = [
      {
        id = "srv";
        label = "yen-mcp (nix run .#yen-mcp)";
        kind = "output";
      }
    ]
    ++ map (t: {
      id = "t:${t}";
      label = t;
      kind = "sink";
    }) mcpTools;
    edges = map (t: {
      from = "srv";
      to = "t:${t}";
    }) mcpTools;
  };
  # aspects by the label prefix they got (yen.lib.labels: the lowest trust over the aspect's files)
  labelRow =
    p: l:
    let
      ns = lib.attrNames (lib.filterAttrs (_: x: x.prefix == p) yen.lib.labels);
    in
    "| `${p}` | ${toString l.trust} | ${toString (lib.length ns)}${
      lib.optionalString (lib.length ns <= 8) ": ${code ns}"
    } |";
  cycles = lib.attrNames (lib.filterAttrs (_: a: a.cycle) yen.lib.schema.aspects);
in
''
  ## Counts

  ${toString (lib.length g.scopes)} scopes, ${toString (lib.length (lib.attrNames yen.kinds))} kinds, ${toString (lib.length (lib.attrNames yen.aspects))} aspects, ${toString (lib.length g.edges)} routed elements.
  A kind with 0 scopes is data: nothing spawns it.

  | Kind | Fields | Spawns | Sinks | Scopes |
  |---|---|---|---|---|
  ${lib.concatMapStringsSep "\n" kindRow (lib.attrNames yen.kinds)}

  | Sink | Given at | Received at | Elements |
  |---|---|---|---|
  ${lib.concatMapStringsSep "\n" sinkRow (sorted (map (e: e.sink) g.edges))}

  ## Capability index

  **Invariants** (`yen.invariants`, Datalog over the fleet's facts). The result is a query on the eval result, not
  readable inside the fleet: `nix eval --impure --json --file query.nix check.violations` (`[ ]` when every one holds).

  | Invariant | File |
  |---|---|
  ${lib.concatMapStringsSep "\n" (
    n:
    "| `${n}` | ${
      files [
        "invariants"
        n
      ]
    } |"
  ) (lib.attrNames yen.invariants)}

  **Stored queries** (`r.ask name args`, or the MCP tool `yen_ask`):

  | Query | Required | Optional | File |
  |---|---|---|---|
  ${lib.concatMapStringsSep "\n" queryRow (sorted (lib.attrNames yen.queries))}

  **MCP tools** (${toString (lib.length mcpTools)}, `mcp/yen-mcp.sh`): ${code mcpTools}.

  ${mermaid mcpView}

  **Trust labels** (`yen.labels`, by file path prefix). An agent edits under a low-trust prefix;
  `(import ./query.nix).floor 3` lists every element its aspects route.

  | Prefix | Trust | Aspects |
  |---|---|---|
  ${lib.concatStringsSep "\n" (lib.mapAttrsToList labelRow yen.labelTable)}

  **Knowledge pack** (`out.rdfPack`, [agent/rdf.nix](modules/agent/rdf.nix)): the sha256 and count of the routing graph
  as sorted N-Triples (the same in every file order), and SHACL shapes from the schema: `nix eval --json .#rdfPack.sha256`.

  **Queries on an eval result** (`r = import ./query.nix`): ${
    code (
      yen.lib.schema.queries
      ++ [
        "context"
        "explain"
        "impact"
        "labels"
        "floor"
        "data"
        "queries"
        "ask"
        "root"
      ]
    )
  }.

  **Engine library** (`yen.lib`): ${
    code (
      lib.filter (
        n:
        !lib.elem n [
          "graphs"
          "datalog"
          "krn"
          "rdf"
          "reduce"
          "program"
          "grants"
          "change"
        ]
      ) (lib.attrNames engine)
    )
  }.
  Reduce strategies: ${code (lib.attrNames engine.reduce)}. Change programs (`yen.lib.program`): ${code (lib.attrNames engine.program)}.
  Graphs (`yen.lib.graphs`): ${code (lib.attrNames engine.graphs)}.

  **The cycle form** (`cycle = { tree, ... }: …`): ${
    if cycles == [ ] then
      "not used in vix; every aspect gives static or arg-reading elements"
    else
      code cycles
  }.
''
