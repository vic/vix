# vix invariants: Datalog rules over the fleet's facts, by reference: a rule is a function of its variables and its literals come
# from `yen.facts` (kind, has, parent, fields, lt) and `yen.relations`. A true `bad` atom is a violation `[ "bad" <invariant> … ]`.
# An agent reads `nix eval --impure --json --file query.nix check.violations` before and after a change;
# `stage` and `yen_program` refuse a change that adds one.
{ yen, lib, ... }:
let
  inherit (yen.facts)
    kind
    has
    parent
    guest
    lt
    ;
  inherit (yen.relations)
    edge
    localForwardClash
    portClash
    followsUndeclared
    ;
  # a clash Nix computed (a field that holds an attrset gives no fact) is a fact of `rel`; one rule makes each a violation
  computed =
    rel: facts:
    facts
    ++ [
      (
        { C }:
        {
          bad = C;
          pos = [ (rel C) ];
        }
      )
    ];
  fact = rel: pos: key: _: {
    head = rel key;
    inherit pos;
  };
  forwards = lib.concatLists (
    lib.mapAttrsToList (
      n: h:
      map (f: {
        host = n;
        port = toString f.bind.port;
      }) h.localForwards
    ) yen.ssh-host
  );
  # the aspects active at some scope
  on = n: yen.lib.schema.aspects.${n}.activeAt > 0;
  # shortcut: reads the aspect's declared `ports` list, so a function element is skipped; upgrade when invariants see `reduced`
  portsOf =
    n:
    let
      v = yen.aspects.${n}.ports or [ ];
    in
    if lib.isList v then v else [ ];
  # the inputs an input follows: the first path segment of its own and each nested `follows` ("" follows nothing)
  follows =
    i:
    lib.optional (lib.isString (i.follows or null) && i.follows != "") (
      lib.head (lib.splitString "/" i.follows)
    )
    ++ lib.concatMap follows (lib.attrValues (lib.filterAttrs (_: lib.isAttrs) (i.inputs or { })));
  inputsOf =
    n:
    let
      f = yen.aspects.${n}.flake-file or { };
    in
    if lib.isAttrs f then f.inputs or { } else { };
in
{
  yen.relations = {
    edge.arity = 3; # the routed elements of the graph: sink, from, to
    localForwardClash.arity = 1; # a local port and the ssh hosts that bind it
    portClash.arity = 1; # a machine or home and a port two services listen on
    followsUndeclared.arity = 1; # an input that a `follows` names and flake.nix does not declare
  };

  yen.invariants = {
    # a gui feature lands only on a user whose machine or home is graphical
    gui-needs-graphical =
      { U, P }:
      {
        bad = U;
        pos = [
          (kind yen.kinds.user U)
          (parent U P)
          (has yen.aspects.vic-gui U)
        ];
        neg = [ (has yen.aspects.graphical P) ];
      };
    # secrets reach only users of trusted machines and homes
    secrets-need-trusted =
      { U, P }:
      {
        bad = U;
        pos = [
          (kind yen.kinds.user U)
          (parent U P)
          (edge "secrets" U U)
        ];
        neg = [ (has yen.aspects.trusted P) ];
      };
    # a CI runner (the ci-runner role: bill, tom, bert) has no users
    runners-no-users =
      { U, P }:
      {
        bad = U;
        pos = [
          (kind yen.kinds.user U)
          (parent U P)
          (has yen.aspects.ci-runner P)
        ];
      };
    # no two ssh hosts bind the same local port: the second forward fails while the first is open
    unique-local-forward = computed localForwardClash (
      lib.concatLists (
        lib.mapAttrsToList (
          port: fs:
          lib.optional (lib.length fs > 1) (
            fact localForwardClash [ ] "${port}:${lib.concatMapStringsSep "," (f: f.host) fs}"
          )
        ) (lib.groupBy (f: f.port) forwards)
      )
    );
    # no two guests share an address: their host routes one /32 per tap
    unique-guest-addr =
      {
        A,
        B,
        X,
      }:
      {
        bad = X;
        pos = [
          (guest.addr A X)
          (guest.addr B X)
          (lt A B)
        ];
      };
    # no two services of one machine or home (or of its users) listen on the same port (the `ports` sink)
    unique-port =
      let
        g = yen.lib.graph;
        placeKinds = map (k: "${k.__kind}:") yen.helpers.places;
        # ports clash per machine or home; a scope with no place (an export) only clashes with itself.
        # shortcut: the place is the longest id prefix whose last segment is a machine or home (ids are `kind:name/…`); upgrade when graph scopes carry their parent
        owner =
          id:
          let
            segs = lib.splitString "/" id;
            isPlace = s: lib.any (p: lib.hasPrefix p s) placeKinds;
            last = lib.foldl' (acc: i: if isPlace (lib.elemAt segs i) then i + 1 else acc) 0 (
              lib.range 0 (lib.length segs - 1)
            );
          in
          if last == 0 then id else lib.concatStringsSep "/" (lib.take last segs);
        given = lib.concatMap (
          e:
          map (p: {
            inherit e;
            key = "${owner e.to}:${toString p.port}";
          }) (portsOf (lib.removePrefix "aspect " e.origin))
        ) (lib.filter (e: e.sink == "ports" && lib.hasPrefix "aspect " e.origin) g.edges);
      in
      computed portClash (
        lib.concatLists (
          lib.mapAttrsToList (
            k: xs:
            lib.optional (lib.length xs > 1) (fact portClash (map (x: edge "ports" x.e.from x.e.to) xs) k)
          ) (lib.groupBy (x: x.key) given)
        )
      );
    # every `follows` names an input that flake.nix declares: the inputs of the active aspects' flake-file elements
    follows-declared =
      let
        inputs = lib.filterAttrs (_: lib.isAttrs) (
          lib.foldl' (a: n: a // inputsOf n) { } (lib.filter on (lib.attrNames yen.aspects))
        );
        succ = lib.mapAttrs (_: follows) inputs;
        by = yen.lib.graphs.transpose succ;
      in
      computed followsUndeclared (
        map (t: fact followsUndeclared [ ] "${t}:${lib.concatStringsSep "," by.${t}}") (
          lib.subtractLists (lib.attrNames inputs) (yen.lib.graphs.nodesOf succ)
        )
      );
  };
}
