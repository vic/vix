# The fleet as a knowledge pack (yen.lib.rdf): the sha256 and count of its sorted N-Triples, and SHACL shapes from the schema.
# The same fleet gives the same hash in every file order, so an agent can tell whether two revisions differ before it reads them.
# Inside the fleet only the routing graph is visible; the full pack is `yen.lib.rdf.share r` over the query.nix result.
# A store such as quipu imports the triples and checks them against `shacl` in a separate, approved step.
{ yen, ... }:
{
  yen.aspects.rdf-pack = {
    at = yen.fleet.vix;
    out =
      { ... }:
      {
        rdfPack =
          removeAttrs (yen.lib.rdf.share {
            graph = yen.lib.graph;
            active = { };
            errors = [ ];
          }) [ "ntriples" ]
          // {
            scope = "routing graph";
            shacl = yen.lib.rdf.shacl { inherit (yen.lib) schema; };
          };
      };
  };
}
