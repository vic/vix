# vix - Vic's Nix Environment

My infra built using my [Dendritic libs](https://dendritic.oeiuwq.com).

Inputs are extracted from modules option [`flake-file.inputs`](https://github.com/vic/flake-file) and pinned via [npins](https://github.com/andir/npins), then loaded using [with-inputs](https://github.com/denful/with-inputs).

Hosts are defined at [`modules/hosts.nix`](modules/hosts.nix) with their respective `den.aspects` at [`modules/hosts/`](modules/hosts/).

My [`den`](modules/den.nix) configuration has two namespaces, `vix` (public) for stuff that is generic enough for others to re-use. And `vic` (private) for everything that has to do with my user.

## Everyday Usage

```console
build
switch
```

---

## Users

Currently only [`vic`](modules/vic) which is applied at all hosts.

## Hosts


| Host     | Platform     | Users      | Notes                   |
| -------- | ------------ | ---------- | ----------------------- |
| bombadil | NixOS ISO    | vic        | USB installer, CI build |
| varda    | MacOS (M4)   | vic        | Mac Mini                |
| yavanna  | MacOS (x86)  | vic        | MacBook Pro             |
| nienna   | NixOS        | vic        | MacBook Pro             |
| mordor   | NixOS        | vic        | ASUS ROG Tower          |
| annatar  | WSL2         | vic        | ASUS ROG Tower          |
| nargun   | NixOS        | vic        | Lenovo Laptop           |
| smaug    | NixOS        | vic        | HP Laptop               |
| bill     | Ubuntu (ARM) | runner/vic | GH Action Runner        |
| bert     | MacOS (ARM)  | runner/vic | GH Action Runner        |
| tom      | Ubuntu       | runner/vic | GH Action Runner        |

---

## Layout

- [`modules/community/vix/`](modules/community/vix): reusable `vix.*` aspects. Others can use them.
- [`modules/vic/`](modules/vic): my user profile. Groups: `shell`, `vcs`, `edit`, `dev`, `sys`.
- [`modules/hosts/`](modules/hosts): one file per host, plus a folder for bigger hosts.
- [`modules/diagrams/`](modules/diagrams): generates the diagrams.

## How it composes

Every level is an include list. Only the leaves hold configuration.

```
den.aspects.frodo                       hosts/frodo.nix      (includes only)
├── vix.laptop, vix.niri-desktop         community/vix/       (reusable features)
├── frodo._.hardware                     hosts/frodo/hardware.nix
├── frodo._.base                         hosts/frodo/base.nix
└── frodo._.users                        hosts/frodo/users.nix

vic.everywhere                          vic/everywhere.nix   (includes only)
└── vic.shell, vic.edit, vic.dev, vic.sys, vic.vcs   (each: vic/<group>/default.nix)
```

- A **host** names its features. Reading the host file tells you what it is.
- A **feature** is one concern across Nix classes (`nixos`, `homeManager`).
- A **sub-aspect** (`_.<name>`) is a named part of a host or feature, such as `frodo._.hardware`.
- A **group** (`vic.shell`, `vic.edit`) only lists its members.

## Add a new host

1. Create `modules/hosts/<h>.nix` as an include list. Keep machine facts (disks, kernel modules) in `den.aspects.<h>._.hardware`. Copy [`nargun.nix`](modules/hosts/nargun.nix) as a start.
2. Add an entry in [`modules/hosts.nix`](modules/hosts.nix), for example `den.hosts.x86_64-linux.<h>.users.vic = { };`.
3. Boot the target machine. Generate the hardware facts there:
   `sudo nixos-facter -o modules/hosts/<h>/_nixos/facter.json`
   Then set `hardware.facter.reportPath` to that file. See [`frodo.nix`](modules/hosts/frodo.nix).
4. If you use disko, point the disk to `/dev/disk/by-id/...`. Do not use `/dev/nvme0n1`. Those names can change between boots.
5. Run `build` for the new host before you switch.

## Hardware facts go stale

`facter.json` is a snapshot. It does not update itself.

Generate it again after you change RAM, disks, or the board:

```console
sudo nixos-facter -o modules/hosts/<h>/_nixos/facter.json
```

Do not trust a build until the file is fresh.

---

## Devshell

Load [shell.nix](shell.nix) using direnv `.envrc` or manually `nix-shell`.

```bash
# .envrc
use nix
```

Other useful commands defined at [Justfile](Justfile)

----

Historical points of this repo:

- [Den without flakes](https://github.com/vic/vix/tree/unflake) **current**
- [Den with flakes + flake-parts](https://github.com/vic/vix/tree/historic/den-flake-parts)
- [Dendritic flake-parts only](https://github.com/vic/vix/tree/historic/dendritic-flake-parts)
- [blueprint](https://github.com/vic/vix/tree/historic/blueprint)
- [flake-parts](https://github.com/vic/vix/tree/historic/flake-parts)
- [olf m1 flake](https://github.com/vic/vix/tree/historic/mk-darwin-system) with [mk-darwin-system](https://github.com/vic/mk-darwin-system)
- other with snowfall-lib lost
