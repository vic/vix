# The fleet as a knowledge pack (sven.lib.rdf): the sha256 and count of its sorted N-Triples, and SHACL shapes from the schema.
# The same fleet gives the same hash in every file order, so an agent can tell whether two revisions differ before it reads them.
# Inside the fleet only the routing graph is visible; the full pack is `sven.lib.rdf.share r` over the query.nix result.
# A store such as quipu imports the triples and checks them against `shacl` in a separate, approved step.
{ sven, ... }:
{
  sven.aspects.rdf-pack = {
    at = sven.fleet.vix;
    out =
      { ... }:
      {
        rdfPack =
          removeAttrs (sven.lib.rdf.share {
            graph = sven.lib.graph;
            active = { };
            errors = [ ];
          }) [ "ntriples" ]
          // {
            scope = "routing graph";
            shacl = sven.lib.rdf.shacl { inherit (sven.lib) schema; };
          };
      };
  };
}
