# vix

Vic's real-world Nix fleet built with [Yen](https://yen.oeiuwq.com/).
One tree of plain Nix modules drives 9 NixOS hosts, 2 Macs, 2 standalone homes, 6 dev shells, and 5 Neovim profiles.
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

| Category | Count | Instances |
| --- | --- | --- |
| NixOS hosts | 9 | `annatar`, `bill`, `bombadil`, `frodo`, `mordor`, `nargun`, `nienna`, `smaug`, `tom` |
| macOS machines | 2 | `bert`, `varda` |
| Standalone homes | 2 | `bitstream`, `nargun` |
| Dev environments | 6 | `fullenv`, `goenv`, `nixenv`, `nodeenv`, `pyenv`, `rustenv` |
| Neovim profiles | 5 | `astrovim`, `lazyvim`, `neovim`, `nvim`, `vscode-vim` |

## How Vix uses Yen

Vix is organized around decoupling facts from behavior, with zero `import-tree` glue and zero string tags.

| Yen feature | Where Vix uses it |
| --- | --- |
| Kind inheritance (`extends`) & ref enums | [`modules/topology/machine.nix`](modules/topology/machine.nix) (`place -> machine -> linux -> host/guest`, `yen.cpu.*`, `yen.desktop.*`) |
| Walled standalone homes (`wall = true`) | [`modules/platforms/home-manager.nix`](modules/platforms/home-manager.nix) (`passUp` isolates OS sinks while sharing `vic/*` features) |
| Roles & tiers via Datalog selectors | [`modules/roles/roles.nix`](modules/roles/roles.nix) and [`modules/roles/tiers.nix`](modules/roles/tiers.nix) (`at.nearest`, `at.under`, `at.not`) |
| Reusable `yen.kits` & `yen.assemblies` | [`modules/kits/github-runner.nix`](modules/kits/github-runner.nix) and [`modules/kits/hardware.nix`](modules/kits/hardware.nix) |
| Pure-Nix `yen.relations` & `yen.invariants` | [`modules/agent/invariants.nix`](modules/agent/invariants.nix) (inspired by [Tupu](https://github.com/vic/tupu): `secrets-need-trusted`, `runners-no-users`, `workstation-has-user`) |
| [Cycle.js](https://cycle.js.org) reactive `cycle = { tree, ... }:` | [`modules/platforms/microvm.nix`](modules/platforms/microvm.nix), [`modules/topology/ssh-hosts.nix`](modules/topology/ssh-hosts.nix), and [`modules/docs/`](modules/docs/fleet.nix) |
| Stored fleet queries (`yen.queries`) | [`modules/agent/queries.nix`](modules/agent/queries.nix) (`fleetSummary`, `freePort`, `portsOf`, `unfreeOn`, `featuresOf`) |
| Self-generated repo files & Starlight docs | [`modules/flake/files.nix`](modules/flake/files.nix), [`modules/flake/ci-workflow.nix`](modules/flake/ci-workflow.nix), and [`modules/docs/`](modules/docs/fleet.nix) |

## Regenerate docs and repo files

```sh
# Update committed README.md and GitHub Actions workflows
nix run .#write-files

# Generate and build the Starlight documentation website under docs/
nix run .#write-docs
pnpm --dir docs build
```

See the full architecture tour, live machine catalog, and invariant reference on the [Vix website](https://vic.github.io/vix/) or explore [Yen](https://yen.oeiuwq.com/).
