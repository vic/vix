# readme: README.md generated from live yen data, written by `nix run .#write-files`.
{
  lib,
  yen,
  inputs,
  ...
}:
let
  # README parts: plain `_` files (import-tree skips them)
  vocab = import ./_vocabulary.nix;
  vocabDirs = import ./_vocabulary-dirs.nix;
  ir = import ./_fleet-ir.nix { inherit yen lib; };
  map' = import ./_readme-map.nix { inherit lib yen ir; };
  inherit (map') mermaid;
  # collapsed section; the blank line after </summary> lets GitHub render the markdown inside
  fold = summary: body: ''
    <details><summary>${summary}</summary>

    ${body}
    </details>
  '';
  host = lib.head (lib.attrNames (lib.filterAttrs (_: h: h.users != [ ]) yen.host));
  home = lib.head (lib.attrValues yen.home);
  intro = ''
    # vix

    Vic's machines, homes and dev envs in [yen](https://github.com/vic/yen): a real-world yen fleet.
    ${toString (lib.length (lib.attrNames yen.host))} NixOS hosts, ${toString (lib.length (lib.attrNames yen.mac))} macs, ${toString (lib.length (lib.attrNames yen.home))} standalone homes, ${toString (lib.length (lib.attrNames yen.env))} dev envs and ${toString (lib.length (lib.attrNames yen.vim))} neovim profiles, from one tree of plain Nix files.
    Every table and diagram below is computed from the fleet when this file is written.

    Generated file: edit `modules/docs/`, then run `nix run .#write-files`.
  '';
  commands = ''
    ## Commands

    ```sh
    nix build .#nixosConfigurations.${host}.config.system.build.toplevel
    nix build '.#homeConfigurations."${home.user.name}@${home.name}".activationPackage'
    nix run .#write-files                                # regenerate this README and ci.yml
    nix build .#write-flake && ./result/bin/write-flake  # regenerate flake.nix from the flake-file sink
    nix flake check                                      # includes checks.x86_64-linux."files/README.md"
    nix eval --json .#ci.matrix                          # every CI build job: host, mac, home, devshell
    nix eval --impure --json --file query.nix check.violations   # invariants: [ ] when all hold
    nix eval --impure --json --file query.nix agent.counts       # scopes, edges, aspects, kinds
    nix eval --impure --json --expr '(import ./query.nix).ask "aspectsOn" { name = "${host}"; }'
    nix eval --impure --json --expr '(import ./query.nix).ask "freePort" { name = "${host}"; }'
    nix eval --offline --impure --file tests.nix failed      # oracles: errors, check.ok, file order, laziness ([ ] when all hold)
    nix eval --offline --impure --file tests.nix e2e.failed  # each machine's and home's settings fingerprint vs vix
    nix run .#yen-mcp                                   # MCP server for agents, on stdio
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
in
{
  yen.aspects.readme = {
    at = yen.system.x86_64-linux;
    files =
      { ci-jobs, ... }:
      {
        files.file."README.md".text = lib.concatStringsSep "\n" [
          intro
          (import ./_readme-tour.nix)
          (import ./_readme-uses.nix)
          commands
          map'.structure
          (import ./_readme-data.nix {
            inherit yen lib mermaid;
            ciJobs = ci-jobs;
          })
          (import ./_readme-wiring.nix {
            inherit yen lib mermaid;
            ciJobs = ci-jobs;
          })
          (import ./_readme-data-user.nix { inherit yen lib mermaid; })
          (import ./_readme-capabilities.nix {
            inherit yen lib mermaid;
            engine = (import inputs.yen).lib;
          })
          (fold "Vocabulary: kinds, sinks, tiers, roles" (
            import ./_readme-vocab.nix { inherit yen lib vocab; }
          ))
          (fold "Directory structure" (import ./_readme-dirs.nix { inherit yen vocabDirs; }))
          (fold "Recipes: add a host, feature, env, ssh host, secret, port" (
            import ./_readme-recipes.nix { inherit yen; }
          ))
          open
          (fold "History" history)
        ];
      };
    # the structure views as JSON, for tools: `nix build .#fleet-ir`
    packages =
      { system, ... }:
      {
        fleet-ir = system.legacyPackages.writeText "fleet-ir.json" (builtins.toJSON ir);
      };
  };
}
