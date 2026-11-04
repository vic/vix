# readme: README.md generated from live yen data, written by `nix run .#write-files`.
# The fleet comes from one tree request (`whole`): the README reads the data it shows as an edge, never as a ref.
{
  lib,
  yen,
  inputs,
  ...
}:
let
  whole.graph = true; # a tree request: the whole fleet, with its data
  # README parts: plain `_` files (import-tree skips them)
  vocab = import ./_vocabulary.nix;
  vocabDirs = import ./_vocabulary-dirs.nix;
  irOf =
    fleet:
    import ./_fleet-ir.nix {
      yen = fleet;
      inherit lib;
    };
  mapOf =
    fleet:
    import ./_readme-map.nix {
      yen = fleet;
      inherit lib;
      ir = irOf fleet;
    };
  # collapsed section; the blank line after </summary> lets GitHub render the markdown inside
  fold = summary: body: ''
    <details><summary>${summary}</summary>

    ${body}
    </details>
  '';
  # the first host with users, and the first home, of the fleet
  hostOf = fleet: lib.head (lib.attrNames (lib.filterAttrs (_: h: h.users != [ ]) fleet.host));
  homeOf = fleet: lib.head (lib.attrValues fleet.home);
  count = xs: toString (lib.length (lib.attrNames xs));
  introOf = fleet: ''
    # vix

    Vic's machines, homes and dev envs in [yen](https://github.com/vic/yen): a real-world yen fleet.
    ${count fleet.host} NixOS hosts, ${count fleet.mac} macs, ${count fleet.home} standalone homes, ${count fleet.env} dev envs and ${count fleet.vim} neovim profiles, from one tree of plain Nix files.
    Every table and diagram below is computed from the fleet when this file is written.

    Generated file: edit `modules/docs/`, then run `nix run .#write-files`.
  '';
  commandsOf = fleet: ''
    ## Commands

    ```sh
    nix build .#nixosConfigurations.${hostOf fleet}.config.system.build.toplevel
    nix build '.#homeConfigurations."${(homeOf fleet).user.name}@${(homeOf fleet).name}".activationPackage'
    nix run .#write-files                                # regenerate this README and ci.yml
    nix build .#write-flake && ./result/bin/write-flake  # regenerate flake.nix from the flake-file sink
    nix flake check                                      # includes checks.x86_64-linux."files/README.md" and yen-lean
    nix eval --json .#ci.matrix                          # every CI build job: host, mac, home, devshell
    nix eval --impure --json --file query.nix check.violations   # invariants: [ ] when all hold
    nix eval --impure --json --file query.nix agent.counts       # scopes, edges, aspects, kinds
    nix eval --impure --json --expr '(import ./query.nix).ask "aspectsOn" { place = { kind = "host"; name = "${hostOf fleet}"; }; }'
    nix eval --impure --json --expr '(import ./query.nix).ask "freePort" { place = { kind = "host"; name = "${hostOf fleet}"; }; }'
    nix eval --offline --impure --file tests.nix failed      # oracles: errors, check.ok, file order, laziness ([ ] when all hold)
    nix run github:vic/yen#yen-mcp                       # yen's MCP server for agents, on stdio
    ```
  '';
  # open decisions: a static list in docs/_open.nix, since vic's notes are not part of the repo
  open = ''
    ## Decisions open

    Each one changes a setting, a structure or an output, so it waits for vic.

    ${lib.concatMapStringsSep "\n" (d: "- ${d}") (import ./_open.nix)}
  '';
  history = ''
    - [yen (current)](https://github.com/vic/vix/tree/yen): Ren rewritten in yen; Ren classes and channels are sinks
    - [Ren](https://github.com/vic/vix/tree/ren)
    - [Den without flakes](https://github.com/vic/vix/tree/historic/den)
    - [Den with flakes + flake-parts](https://github.com/vic/vix/tree/historic/den-flake-parts)
    - [Dendritic flake-parts only](https://github.com/vic/vix/tree/historic/dendritic-flake-parts)
    - [blueprint](https://github.com/vic/vix/tree/historic/blueprint)
    - [flake-parts](https://github.com/vic/vix/tree/historic/flake-parts)
    - [old m1 flake](https://github.com/vic/vix/tree/historic/mk-darwin-system) with [mk-darwin-system](https://github.com/vic/mk-darwin-system)
    - other with snowfall-lib lost
  '';
  # README.md of the fleet, its CI jobs and the runner of each system; each job shows its runner
  readmeOf =
    fleet: jobs: runners:
    let
      inherit (mapOf fleet) mermaid structure;
      ciJobs = lib.mapAttrs (_: j: j // { runner = runners.${j.system}.label or null; }) jobs;
    in
    lib.concatStringsSep "\n" [
      (introOf fleet)
      (import ./_readme-tour.nix)
      (import ./_readme-uses.nix)
      (commandsOf fleet)
      structure
      (import ./_readme-data.nix {
        yen = fleet;
        inherit lib mermaid ciJobs;
      })
      (import ./_readme-wiring.nix {
        yen = fleet;
        inherit
          lib
          mermaid
          ciJobs
          runners
          ;
      })
      (import ./_readme-data-user.nix {
        yen = fleet;
        inherit lib mermaid;
      })
      (import ./_readme-capabilities.nix {
        yen = fleet;
        inherit lib mermaid inputs;
        engine = (import inputs.yen).lib;
      })
      (fold "Vocabulary: kinds, sinks, tiers, roles" (
        import ./_readme-vocab.nix {
          yen = fleet;
          inherit lib vocab;
        }
      ))
      (fold "Directory structure" (
        import ./_readme-dirs.nix {
          yen = fleet;
          inherit vocabDirs;
        }
      ))
      (fold "Recipes: add a host, feature, env, ssh host, secret, port" (
        import ./_readme-recipes.nix { yen = fleet; }
      ))
      open
      (fold "History" history)
    ];
in
{
  yen.aspects.readme = {
    at = yen.system.x86_64-linux;
    cycle =
      {
        tree,
        scope,
        ci-jobs,
        runners,
        ...
      }:
      {
        tree = [ whole ];
        files = [
          {
            files.file."README.md".text = readmeOf (tree.select whole) (lib.head (ci-jobs ++ [ { } ])) (
              lib.head (runners ++ [ { } ])
            );
          }
        ];
        # the structure views as JSON, for tools: `nix build .#fleet-ir`
        packages = [
          {
            fleet-ir = scope.legacyPackages.writeText "fleet-ir.json" (
              builtins.toJSON (irOf (tree.select whole))
            );
          }
        ];
      };
  };
}
