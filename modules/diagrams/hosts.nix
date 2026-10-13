# Per-host entries, graph IRs and text summaries.
{ lib, ... }:
{
  perSystem =
    {
      pkgs,
      rc,
      diagram,
      fleetCapture,
      allHosts,
      projectOf,
      classesOf,
      fileEntry,
      ...
    }:
    let
      graphs = lib.genAttrs' allHosts (host: lib.nameValuePair host.name (projectOf "host" host.name));
    in
    {
      _module.args = {
        # Per-host graph IRs, used by the fleet DAG.
        hostGraphs = graphs;

        hostEntries = lib.concatMap (
          host:
          diagram.export.entityEntries { inherit pkgs rc; } {
            entity = graphs.${host.name};
            name = host.name;
            dir = "hosts/${host.name}";
            viewDefs = rc.views.host ++ rc.views.classViews (classesOf graphs.${host.name});
          }
        ) allHosts;

        hostTextEntries = map (
          host:
          fileEntry "hosts/${host.name}" host.name "summary" {
            ext = "md";
            tool = null;
            drv = pkgs.writeText "${host.name}-summary.md" (
              diagram.text.hostSummary {
                graph = graphs.${host.name};
                inherit fleetCapture;
              }
            );
          }
        ) allHosts;
      };
    };
}
