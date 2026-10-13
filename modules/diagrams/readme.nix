# README written next to the generated diagrams; host list comes from den.hosts.
{ den, lib, ... }:
let
  hostNames = lib.concatMap builtins.attrNames (builtins.attrValues den.hosts);
in
{
  perSystem =
    { pkgs, ... }:
    {
      _module.args.readmeDrv = pkgs.writeText "README.md" ''
        # vix diagrams

        Aspect-resolution visualization via `den-diagram`.

        ## Directory Structure

        ```
        diagrams/
          hosts/<host>/             — per-host views (aspects, dag, seq, ...)
          hosts/<host>/users/<user> — per-user views
          homes/<home>/             — per-home views
          fleet/                    — fleet-wide views
        ```

        ## Hosts

        ${lib.concatMapStringsSep ", " (h: "`${h}`") hostNames}

        ## Per-Host Views

        `dag`, `aspects`, `simple`, `ctx`, `scope-seq`, `scope-seq-full`,
        `policy-seq`, `scope-edges`, `providers`, `providers-resolved`,
        `adapters`, `decisions`, `declared`, `class-<name>` (per class),
        `diff-classes`, `c4component`, `ir` (Graph IR, JSON).

        ## Fleet Views

        `pipe-flow`, `scope-topology`, `aspect-matrix`, `policy-resolution`,
        `pipe-sequence`, `fleet-dag`, `namespace`, `fleet-ir` (JSON),
        `summary` (text, fleet + per-host).

        ## Usage

        ```bash
        nix run .#write-diagrams    # writes all views
        ```
      '';
    };
}
