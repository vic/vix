# Fleet-wide views, graph IR, namespace graph and text summary.
{ den, lib, ... }:
{
  perSystem =
    {
      pkgs,
      rc,
      diagram,
      fleetCapture,
      hostGraphs,
      fileEntry,
      ...
    }:
    let
      # Markdown page + svg (from mermaid source) entries for one fleet view.
      view =
        name: title: source:
        map (fileEntry "fleet" "fleet" name) [
          {
            ext = "md";
            tool = null;
            drv = pkgs.writeText "${name}.md" "# ${title}\n\n![${title}](./${name}.mmd.svg)\n\n```mermaid\n${source}\n```\n";
          }
          {
            ext = "svg";
            tool = "mmd";
            drv = rc.mmdSourceToSvg name source;
          }
        ];

      capture =
        name: title: fn:
        view name title (fn fleetCapture);
      irJson = diagram.fleetGraph.toJSON { inherit fleetCapture hostGraphs; };
      summary = pkgs.writeText "fleet-summary.md" (diagram.text.fleetSummary fleetCapture);
    in
    {
      _module.args = {
        fleetEntries =
          diagram.export.fleetEntries { inherit pkgs; } {
            fleetData = diagram.fleet.of {
              hosts = den.hosts;
              flakeName = "vix";
            };
            viewDefs = rc.views.fleet;
          }
          ++ capture "pipe-flow" "Pipe Flow" rc.render.toPipeFlowMermaid
          ++ capture "scope-topology" "Scope Topology" rc.render.toScopeTopologyMermaid
          ++ capture "aspect-matrix" "Aspect Coverage" rc.render.toAspectMatrixMermaid
          ++ capture "policy-resolution" "Policy Resolution Map" rc.render.toPolicyResolutionMapMermaid
          ++ capture "pipe-sequence" "Pipe Sequence" rc.render.toPipeSequenceMermaid
          ++ view "fleet-dag" "Fleet DAG" (rc.render.toFleetDagMermaid { inherit fleetCapture hostGraphs; })
          ++ view "namespace" "Namespace" (
            rc.renderDense.toMermaid (diagram.graph.ofNamespace { aspects = den.aspects or { }; })
          )
          ++ [
            (fileEntry "fleet" "fleet" "fleet-ir" {
              ext = "json";
              tool = null;
              drv = pkgs.runCommand "fleet-ir.json" { nativeBuildInputs = [ pkgs.jq ]; } ''
                echo ${lib.escapeShellArg irJson} | jq . > $out
              '';
            })
            (fileEntry "fleet" "fleet" "summary" {
              ext = "md";
              tool = null;
              drv = summary;
            })
          ];
      };
    };
}
