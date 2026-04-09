# vix - Vic's Nix Environment

My infra built using my [Dendritic libs](https://dendritic.oeiuwq.com).

Inputs are extracted from modules option [`flake-file.inputs`](https://github.com/vic/flake-file) and pinned via [npins](https://github.com/andir/npins), then loaded using [with-inputs](https://github.com/vic/with-inputs).

Hosts are defined at [`modules/hosts.nix`](modules/hosts.nix) with their respective `den.aspects` at [`modules/hosts/`](modules/hosts/).

My [`den`](modules/den.nix) configuration has two namespaces, `vix` (public) for stuff that is generic enough for others to re-use. And `vic` (private) for everything that has to do with my user.

## Everyday Usage

```console
just build
just switch
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
