# The fleet as a knowledge pack (yen.lib.rdf): the sha256 and count of its sorted N-Triples, and SHACL shapes from the schema.
# The same fleet gives the same hash in every file order, so an agent can tell whether two revisions differ before it reads them.
# Inside the fleet only the routing graph is visible (one `whole` tree request); the full pack is `yen.lib.rdf.share r`
# over the query.nix result. A store such as quipu imports the triples and checks them against `shacl` in a separate,
# approved step.
{ yen, ... }:
let
  whole.graph = true; # a tree request: the whole fleet, with its structure queries
  # the pack of the fleet: its routing graph, and the shapes of its schema
  packOf =
    fleet:
    removeAttrs (yen.lib.rdf.share {
      graph = fleet.lib.graph;
      active = { };
      errors = [ ];
    }) [ "ntriples" ]
    // {
      scope = "routing graph";
      shacl = yen.lib.rdf.shacl { inherit (fleet.lib) schema; };
    };
in
{
  yen.aspects.rdf-pack = {
    at = yen.fleet.vix;
    cycle =
      { tree, ... }:
      {
        tree = [ whole ];
        out = [ { rdfPack = packOf (tree.select whole); } ];
      };
  };
}
