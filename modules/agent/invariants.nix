# vix invariants: Datalog rules over the fleet's facts (`kind:K:ID`, `has:ASPECT:ID`, `edge:SINK:FROM:TO`).
# A true `bad:` atom is a violation. An agent reads `nix eval --impure --json --file query.nix check.violations`
# before and after a change; `stage` and `sven_program` refuse a change that adds one.
{ sven, lib, ... }:
let
  # users with their place (machine or home) as parent
  users = scopes: lib.filter (s: s.kind == "user" && s.parent != null) scopes;
  forwards = lib.concatLists (
    lib.mapAttrsToList (
      n: h:
      map (f: {
        host = n;
        port = toString f.bind.port;
      }) h.localForwards
    ) sven.ssh-host
  );
  on = active: n: lib.any lib.id (lib.attrValues active.${n});
  # shortcut: reads the aspect's declared `ports` list, so a function element is skipped; upgrade when invariants see `reduced`
  portsOf =
    n:
    let
      v = sven.aspects.${n}.ports or [ ];
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
      f = sven.aspects.${n}.flake-file or { };
    in
    if lib.isAttrs f then f.inputs or { } else { };
in
{
  sven.invariants = {
    # a gui feature lands only on a user whose machine or home is graphical
    gui-needs-graphical =
      { scopes, ... }:
      map (u: {
        head = "bad:gui-off-graphical:${u.id}";
        pos = [ "has:vic-gui:${u.id}" ];
        neg = [ "has:graphical:${u.parent.id}" ];
      }) (users scopes);
    # secrets reach only users of trusted machines and homes
    secrets-need-trusted =
      { scopes, ... }:
      map (u: {
        head = "bad:secrets-off-trusted:${u.id}";
        pos = [ "edge:secrets:${u.id}:${u.id}" ];
        neg = [ "has:trusted:${u.parent.id}" ];
      }) (users scopes);
    # a CI runner (the ci-runner role: bill, tom, bert) has no users
    runners-no-users =
      { scopes, ... }:
      map (u: {
        head = "bad:runner-has-user:${u.id}";
        pos = [ "has:ci-runner:${u.parent.id}" ];
      }) (users scopes);
    # no two ssh hosts bind the same local port: the second forward fails while the first is open
    unique-local-forward =
      _:
      lib.concatLists (
        lib.mapAttrsToList (
          port: fs:
          lib.optional (lib.length fs > 1) {
            head = "bad:local-forward-clash:${port}:${lib.concatMapStringsSep "," (f: f.host) fs}";
          }
        ) (lib.groupBy (f: f.port) forwards)
      );
    # no two guests share an address: their host routes one /32 per tap
    unique-guest-addr =
      _:
      lib.concatLists (
        lib.mapAttrsToList (
          addr: ns:
          lib.optional (lib.length ns > 1) {
            head = "bad:guest-addr-clash:${addr}:${lib.concatStringsSep "," ns}";
          }
        ) (lib.groupBy (n: sven.guest.${n}.addr) (lib.attrNames sven.guest))
      );
    # no two services of one machine or home (or of its users) listen on the same port (the `ports` sink)
    unique-port =
      { scopes, graph, ... }:
      let
        byId = lib.listToAttrs (map (s: lib.nameValuePair s.id s) scopes);
        # ports clash per machine or home; a scope with no place (an export) only clashes with itself
        owner =
          id:
          let
            p = sven.helpers.place byId.${id};
          in
          if p == null then id else p.id;
        given = lib.concatMap (
          e:
          map (p: {
            inherit e;
            key = "${owner e.to}:${toString p.port}";
          }) (portsOf (lib.removePrefix "aspect " e.origin))
        ) (lib.filter (e: e.sink == "ports" && lib.hasPrefix "aspect " e.origin) graph.edges);
      in
      lib.concatLists (
        lib.mapAttrsToList (
          k: xs:
          lib.optional (lib.length xs > 1) {
            head = "bad:port-clash:${k}";
            pos = map (x: "edge:ports:${x.e.from}:${x.e.to}") xs;
          }
        ) (lib.groupBy (x: x.key) given)
      );
    # every `follows` names an input that flake.nix declares: the inputs of the active aspects' flake-file elements
    follows-declared =
      { active, ... }:
      let
        inputs = lib.filterAttrs (_: lib.isAttrs) (
          lib.foldl' (a: n: a // inputsOf n) { } (lib.filter (on active) (lib.attrNames sven.aspects))
        );
        succ = lib.mapAttrs (_: follows) inputs;
        by = sven.lib.graphs.transpose succ;
      in
      map (t: { head = "bad:follows-undeclared:${t}:${lib.concatStringsSep "," by.${t}}"; }) (
        lib.subtractLists (lib.attrNames inputs) (sven.lib.graphs.nodesOf succ)
      );
  };
}
