# One sven-mcp tool call. Inputs come from the environment, never from string interpolation:
# SVEN_FLAKE (the fleet flake ref), SVEN_FLEET (fleet dir), SVEN_TOOL, SVEN_ARGS (path of the arguments JSON).
let
  env = builtins.getEnv;
  fleet = /. + env "SVEN_FLEET";
  flake = builtins.getFlake (env "SVEN_FLAKE");
  inputs = flake.inputs // {
    self = flake;
  }; # vix reads inputs.self (files root, ci.yml, devshell)
  sven = import inputs.sven;
  base = {
    imports = [ (inputs.import-tree (fleet + "/modules")) ];
    _module.args = {
      inherit inputs;
      inherit (inputs.nixpkgs) lib;
    };
  };
  r = sven.lib.eval base;
  safe = sven.lib.jsonSafe;
  args = builtins.fromJSON (builtins.readFile (env "SVEN_ARGS"));
  opt =
    names:
    builtins.intersectAttrs (builtins.listToAttrs (
      map (n: {
        name = n;
        value = null;
      }) names
    )) args;
  tools = {
    schema = r.agent.schema;
    check = (removeAttrs r.check [ "why" ]) // {
      why = builtins.listToAttrs (
        map (v: {
          name = v;
          value = r.check.why v;
        }) r.check.violations
      );
    };
    context = r.context args.id (opt [
      "maxEdges"
      "maxAspects"
    ]);
    explain = r.explain args.aspect args.scope (args.depth or 3);
    errors = builtins.filter (e: !(args ? code) || (e.code or null) == args.code) r.agent.errors;
    declared_in = r.declaredIn args.path;
    export = sven.lib.rdf.share r;
    stage = removeAttrs (sven.lib.stage {
      inherit base;
      change = args.change;
    }) [ "render" ];
    queries = r.queries;
    ask = r.ask args.name (args.args or { });
    impact = r.impact args.id (opt [
      "hops"
      "sinks"
      "max"
    ]);
    labels = {
      labels = r.labels;
      floor =
        if args ? floor then
          map (e: {
            inherit (e) aspect trust file;
            inherit (e.edge) sink from to;
          }) (r.floor args.floor)
        else
          [ ];
    };
    why_not = {
      holds = builtins.elem args.atom r.check.violations;
      whyNot = r.check.whyNot args.atom;
      why = r.check.why args.atom;
    };
    program = sven.lib.program.dryRun {
      inherit base r;
      prog = args.program;
    };
  };
in
safe tools.${env "SVEN_TOOL"}
