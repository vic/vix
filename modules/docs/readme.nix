# Generates a concise, scannable root `README.md` directly from the live Vix Yen fleet.
{ yen, ... }:
let
  b = builtins;
  d = yen.helpers.vixDocs;

  allHosts = {
    instances = yen.kinds.host;
  };
  allMacs = {
    instances = yen.kinds.mac;
  };
  allHomes = {
    instances = yen.kinds.home;
  };
  allEnvs = {
    instances = yen.kinds.env;
  };
  allVims = {
    instances = yen.kinds.vim;
  };
  sortNames = xs: b.sort (x: y: x.name < y.name) xs;
in
{
  yen.docPage.readme = {
    title = "vix";
    section = yen.docSection.home;
    order = 1;
    readmeOnly = true;
    summary = "Vic's NixOS, macOS, Home Manager, devShell, and Neovim fleet built cleanly with Yen.";
  };

  yen.aspects.doc-readme = {
    at = yen.docPage.readme;
    cycle =
      { tree, ... }:
      (hosts: macs: homes: envs: vims: {
        tree = [
          allHosts
          allMacs
          allHomes
          allEnvs
          allVims
        ];
        docBody = ''
          # vix

          Vic's real-world Nix fleet built with ${d.yen}.
          One tree of plain Nix modules drives ${toString (b.length hosts)} NixOS hosts, ${toString (b.length macs)} Macs, ${toString (b.length homes)} standalone homes, ${toString (b.length envs)} dev shells, and ${toString (b.length vims)} Neovim profiles.
          Every table on this page and the [Vix documentation site](https://vic.github.io/vix/) is generated live from the fleet itself.

          ## Activate, verify, and query

          ```sh
          # Verify the whole fleet (types, Datalog invariants, reactive guards)
          nix eval .#yen.ok
          nix eval --json .#yen.check.violations

          # Activate NixOS, macOS, or standalone Home Manager
          sudo nixos-rebuild switch --flake .#frodo
          sudo darwin-rebuild switch --flake .#varda
          home-manager switch --flake .#vic@nargun

          # Enter a dev shell or launch a Neovim profile
          nix develop .#rustenv
          nix run .#nvim

          # Run live fleet queries from your terminal
          nix eval --json .#yen.ask.fleetSummary --apply 'f: f {}'
          nix eval --json .#yen.ask.freePort --apply 'f: f { place = "frodo"; }'
          nix eval --json .#yen.ask.featuresOf --apply 'f: f { vim = "nvim"; }'
          ```

          ## Live fleet at a glance

          ${d.table
            [ "Category" "Count" "Instances" ]
            [
              [
                "NixOS hosts"
                (toString (b.length hosts))
                (b.concatStringsSep ", " (map (h: "`${h.name}`") hosts))
              ]
              [
                "macOS machines"
                (toString (b.length macs))
                (b.concatStringsSep ", " (map (m: "`${m.name}`") macs))
              ]
              [
                "Standalone homes"
                (toString (b.length homes))
                (b.concatStringsSep ", " (map (h: "`${h.name}`") homes))
              ]
              [
                "Dev environments"
                (toString (b.length envs))
                (b.concatStringsSep ", " (map (e: "`${e.name}`") envs))
              ]
              [
                "Neovim profiles"
                (toString (b.length vims))
                (b.concatStringsSep ", " (map (v: "`${v.name}`") vims))
              ]
            ]
          }

          ## How Vix uses Yen

          Vix is organized around decoupling facts from behavior, with zero `import-tree` glue and zero string tags.

          ${d.table
            [ "Yen feature" "Where Vix uses it" ]
            [
              [
                "Kind inheritance (`extends`) & ref enums"
                "[`modules/topology/machine.nix`](modules/topology/machine.nix) (`place -> machine -> linux -> host/guest`, `yen.cpu.*`, `yen.desktop.*`)"
              ]
              [
                "Walled standalone homes (`wall = true`)"
                "[`modules/platforms/home-manager.nix`](modules/platforms/home-manager.nix) (`passUp` isolates OS sinks while sharing `vic/*` features)"
              ]
              [
                "Roles & tiers via Datalog selectors"
                "[`modules/roles/roles.nix`](modules/roles/roles.nix) and [`modules/roles/tiers.nix`](modules/roles/tiers.nix) (`at.nearest`, `at.under`, `at.not`)"
              ]
              [
                "Reusable `yen.kits` & `yen.assemblies`"
                "[`modules/kits/github-runner.nix`](modules/kits/github-runner.nix) and [`modules/kits/hardware.nix`](modules/kits/hardware.nix)"
              ]
              [
                "Pure-Nix `yen.relations` & `yen.invariants`"
                "[`modules/agent/invariants.nix`](modules/agent/invariants.nix) (inspired by ${d.tupu}: `secrets-need-trusted`, `runners-no-users`, `workstation-has-user`)"
              ]
              [
                "${d.cyclejs} reactive `cycle = { tree, ... }:`"
                "[`modules/platforms/microvm.nix`](modules/platforms/microvm.nix), [`modules/topology/ssh-hosts.nix`](modules/topology/ssh-hosts.nix), and [`modules/docs/`](modules/docs/fleet.nix)"
              ]
              [
                "Stored fleet queries (`yen.queries`)"
                "[`modules/agent/queries.nix`](modules/agent/queries.nix) (`fleetSummary`, `freePort`, `portsOf`, `unfreeOn`, `featuresOf`)"
              ]
              [
                "Self-generated repo files & Starlight docs"
                "[`modules/flake/files.nix`](modules/flake/files.nix), [`modules/flake/ci-workflow.nix`](modules/flake/ci-workflow.nix), and [`modules/docs/`](modules/docs/fleet.nix)"
              ]
            ]
          }

          ## Regenerate docs and repo files

          ```sh
          # Update committed README.md and GitHub Actions workflows
          nix run .#write-files

          # Generate and build the Starlight documentation website under docs/
          nix run .#write-docs
          pnpm --dir docs build
          ```

          See the full architecture tour, live machine catalog, and invariant reference on the [Vix website](https://vic.github.io/vix/) or explore [Yen](https://yen.oeiuwq.com/).
        '';
      })
        (sortNames (tree.select allHosts))
        (sortNames (tree.select allMacs))
        (sortNames (tree.select allHomes))
        (sortNames (tree.select allEnvs))
        (sortNames (tree.select allVims));
  };
}
