# Verification & Recipes pages: Invariants & Live Queries, Recipes & CI.
{ yen, ... }:
let
  d = yen.helpers.vixDocs;
in
{
  yen.docPage.invariants-and-queries = {
    title = "Invariants & Live Queries";
    section = yen.docSection.verify;
    order = 10;
    summary = "Enforce fleet-wide rules with pure-Nix Datalog invariants, reactive guards, trust labels, and stored `.#yen.ask` queries.";
  };

  yen.aspects.doc-verify-invariants = {
    at = yen.docPage.invariants-and-queries;
    docBody = ''
      Before any host builds, Vix verifies the entire fleet in one ${d.tupu}-inspired Datalog solver and reactive pass.
      If any rule fails, deployable flake outputs fail closed and `.#invalid-flake-errors` explains every violation.

      ## Fleet invariants and reactive guards

      ${d.table
        [ "Rule" "Kind" "What it guarantees" ]
        [
          [
            "`gui-needs-graphical`"
            "Datalog invariant"
            "GUI features (`vic-gui`) only land under a `graphical` machine or home"
          ]
          [
            "`secrets-need-trusted`"
            "Datalog invariant"
            "SOPS secrets never reach an untrusted machine or home"
          ]
          [
            "`runners-no-users`"
            "Datalog invariant"
            "Bare CI runners (`bill`, `tom`, `bert`) never spawn human users"
          ]
          [
            "`workstation-has-user`"
            "Datalog invariant (`yen.relations.has-user`)"
            "Every machine with `workstation = true` spawns at least one user"
          ]
          [
            "`unique-guest-addr`"
            "Datalog invariant"
            "No two MicroVM guests claim the same routed IP address"
          ]
          [
            "`every-doc-page-has-summary`"
            "Datalog invariant"
            "Every self-documented Vix page carries a non-empty summary"
          ]
          [
            "`unique-port-guard`"
            "Reactive sink guard"
            "No two services on the same machine claim the same port"
          ]
          [
            "`follows-declared-guard`"
            "Reactive sink guard"
            "Every `flake-file` input `follows` targets a declared input"
          ]
          [
            "`ssh-jumps`"
            "${d.cyclejs} graph guard"
            "No `ProxyJump` cycle exists across `yen.ssh-host.*`"
          ]
          [
            "`secret-files`"
            "Reactive sink guard"
            "Every encrypted file in `modules/vic/secrets/` has a typed `yen.secret.*`"
          ]
        ]
      }

      ## Verify and query Vix from your terminal

      Because `yen.mkFlake` attaches `.#yen` automatically, every check and stored query runs in pure Nix without `--impure`:

      ${d.sh ''
        # Fleet health, errors, warnings, and Datalog violations
        nix eval .#yen.ok
        nix eval --json .#yen.errors
        nix eval --json .#yen.check.violations

        # Live stored queries (`modules/agent/queries.nix`)
        nix eval --json .#yen.ask.fleetSummary --apply 'f: f {}'
        nix eval --json .#yen.ask.freePort --apply 'f: f { place = "frodo"; }'
        nix eval --json .#yen.ask.portsOf --apply 'f: f { place = "frodo"; }'
        nix eval --json .#yen.ask.unfreeOn --apply 'f: f { place = "frodo"; }'
        nix eval --json .#yen.ask.featuresOf --apply 'f: f { vim = "nvim"; }'

        # Trust labels for agent staging (`modules/agent/labels.nix`)
        nix eval --json .#yen.labels
      ''}

      ## Pure-Nix Datalog relations and invariants

      ${d.file ../agent/invariants.nix "modules/agent/invariants.nix"}

      Next, see everyday workflows for adding hosts, features, secrets, and running CI in [Recipes & CI](/verify/recipes-and-ci/).
    '';
  };

  yen.docPage.recipes-and-ci = {
    title = "Recipes & CI";
    section = yen.docSection.verify;
    order = 20;
    summary = "Add a host, feature, dev env, secret, or port to Vix, and see how Vix generates its own CI matrix and website.";
  };

  yen.aspects.doc-verify-recipes = {
    at = yen.docPage.recipes-and-ci;
    docBody = ''
      ## Add a NixOS host

      Create `modules/hosts/<name>/default.nix` with typed facts only.
      Hardware, desktop, and user features activate automatically, and `modules/hosts/<name>/_nixos/` loads via `autoinclude`:

      ${d.nix ''
        { yen, ... }:
        {
          yen.host.elrond = {
            system = yen.system.x86_64-linux;
            users = [ yen.user.vic ];
            workstation = true;
            trusted = true;
            cpu = yen.cpu.amd;
            desktops = [ yen.desktop.kde yen.desktop.niri ];
          };
        }
      ''}

      ## Add a user feature

      Drop one small file under `modules/vic/<area>/<name>.nix` gated by a tier aspect:

      ${d.nix ''
        { yen, ... }:
        {
          yen.aspects.my-tool = {
            at = yen.aspects.vic-full;
            homeManager = { pkgs, ... }: {
              home.packages = [ pkgs.gh pkgs.jq ];
            };
          };
        }
      ''}

      ## Claim a service port safely

      Ask the fleet for the next free port on a machine, then declare it next to the service so `unique-port-guard` prevents clashes:

      ${d.sh ''
        nix eval --json .#yen.ask.freePort --apply 'f: f { place = "frodo"; }'
      ''}

      ## Regenerate flake.nix, workflows, README, and docs

      Vix keeps its own `flake.nix`, `README.md`, `.github/workflows/ci.yml`, `.github/workflows/gh-pages.yml`, and Starlight website generated from `modules/`:

      ${d.sh ''
        # Regenerate flake.nix from aspect `flake-file` emissions
        nix run .#write-flake

        # Regenerate README.md and GitHub Actions workflows
        nix run .#write-files

        # Generate and build the Starlight website
        nix run .#write-docs
        pnpm --dir docs build
      ''}

      ## CI gate and matrix

      Every host, Mac, standalone home, devShell, and file-freshness check emits a job into `ci-jobs` (`modules/flake/ci.nix`).
      The generated `yen-gate` job verifies `.#yen.ok`, `.#yen.errors`, `.#yen.check.violations`, and `.#yen.undefined` before builds run.
    '';
  };
}
