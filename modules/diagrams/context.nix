# Shared render context for every diagrams/* file, exposed as perSystem
# module args: diagram, rc, fleetCapture, allHosts, projectOf, classesOf, fileEntry.
{
  den,
  lib,
  inputs,
  ...
}:
let
  diagram = inputs.den-diagram.lib;
in
{
  flake-file.inputs.den-diagram.url = "github:denful/den-diagram";
  perSystem =
    { pkgs, mermaidCli, ... }:
    let
      fleetCapture = den.lib.capture.captureFleet { };
    in
    {
      _module.args = {
        inherit diagram fleetCapture;

        allHosts = lib.concatMap builtins.attrValues (builtins.attrValues den.hosts);

        rc = diagram.renderContext {
          inherit pkgs mermaidCli;
          theme = diagram.themeFromBase16 {
            inherit pkgs;
            scheme = "rebecca";
          };
          mermaidConfig = {
            layout = "elk";
            elk = {
              mergeEdges = true;
              nodePlacementStrategy = "BRANDES_KOEPF";
            };
            flowchart.wrappingWidth = 600;
          };
        };

        # Export entry: dir/name/view locate it; attrs carry ext/tool/drv.
        fileEntry =
          dir: name: view: attrs:
          { inherit dir name view; } // attrs;

        # Class names present in a projected entity graph.
        classesOf = entity: lib.unique (lib.concatMap (n: n.classes or [ ]) entity.nodes);

        # Scope projection of one entity kind ("host" | "user" | "home").
        projectOf =
          kind: name:
          diagram.projectScope {
            inherit fleetCapture kind name;
          };
      };
    };
}
