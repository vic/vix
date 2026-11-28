# vix invariants: pure-Nix Datalog rules over fleet facts + Cycle reactive port & follows guards (zero strings!).
{
  yen,
  lib,
  ...
}:
let
  inherit (yen.facts)
    kind
    has
    parent
    edge
    guest
    machine
    ;
  followsOf =
    i:
    lib.optional (lib.isString (i.follows or null) && i.follows != "") (
      lib.head (lib.splitString "/" i.follows)
    )
    ++ lib.concatMap followsOf (lib.attrValues (lib.filterAttrs (_: lib.isAttrs) (i.inputs or { })));
  ownerOf =
    scopeId:
    (
      segs:
      if lib.length segs >= 2 && lib.hasPrefix "user:" (lib.last segs) then
        lib.concatStringsSep "/" (lib.init segs)
      else
        scopeId
    )
      (lib.splitString "/" scopeId);
in
{
  # Pure-Nix Datalog relations reused across invariants and queries (zero strings!)
  yen.relations = {
    has-user =
      { P, U }:
      {
        head = yen.relations.has-user P;
        pos = [
          (kind yen.kinds.user U)
          (parent U P)
        ];
      };

    serves-tunnel =
      { S, H }:
      {
        head = yen.relations.serves-tunnel S H;
        pos = [ (yen.facts.ssh-host.forwardsServedBy S H) ];
      };
  };

  yen.invariants = {
    # A gui feature lands only on a user whose machine or home is graphical
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

    # Secrets reach only users of trusted machines and homes (real SinkRef!)
    secrets-need-trusted =
      { U, P }:
      {
        bad = U;
        pos = [
          (kind yen.kinds.user U)
          (parent U P)
          (edge yen.kinds.user.sinks.secrets U U)
        ];
        neg = [ (has yen.aspects.trusted P) ];
      };

    # A CI runner (`ci-runner` role: bill, tom, bert) has no users
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

    # Every workstation must spawn at least one user (uses `yen.relations.has-user`)
    workstation-has-user =
      { M }:
      {
        bad = M;
        pos = [
          (kind yen.kinds.machine M)
          (machine.workstation M true)
        ];
        neg = [ (yen.relations.has-user M) ];
      };

    # No two guests share an address (their host routes one /32 per tap)
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
        ];
        when = [ (A.lt B) ];
      };
  };

  # Reactive port-uniqueness guard across all users on each place (catches even function-emitted ports!)
  yen.aspects.unique-port-guard = {
    at = yen.root;
    errors =
      { served, ... }:
      lib.concatLists (
        lib.mapAttrsToList
          (
            k: xs:
            lib.optional (lib.length xs > 1)
              "unique-port: clash at ${k} (${lib.concatMapStringsSep ", " (x: x.what) xs})"
          )
          (
            lib.groupBy (x: x.key) (
              lib.concatMap (
                e:
                map (p: {
                  inherit (p) what;
                  key = "${ownerOf e.from}:${toString p.port}";
                }) (if lib.isList e.value then e.value else [ e.value ])
              ) served
            )
          )
      );
  };

  # Reactive flake-file `follows` guard: every `follows` must name an input declared in `flake-file.inputs`!
  yen.aspects.follows-declared-guard = {
    at = yen.root;
    errors =
      { flake-file, ... }:
      (
        declared:
        lib.concatLists (
          lib.mapAttrsToList (
            inpName: spec:
            map (target: "follows-declared: input `${inpName}` follows undeclared `${target}`") (
              lib.filter (t: !(declared ? ${t})) (if lib.isAttrs spec then followsOf spec else [ ])
            )
          ) declared
        )
      )
        (flake-file.inputs or { });
  };
}
