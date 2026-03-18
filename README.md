# vix - Vic's Nix Environment

My infra without flakes using my [Dendritic libs](https://dendrix.oeiuwq.com/Dendritic-Ecosystem.html#vics-dendritic-libraries).

Inputs are defined as [`flake-file.inputs`](https://github.com/vic/flake-file) options and pinned via [npins](https://github.com/andir/npins).

## Hosts

All hosts are defined in [`modules/hosts/`](modules/hosts/)

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

## Everyday Usage

```console
just build
just switch
```

---

## Users

Currently only [`vic`](modules/users/vic) which is applied at all hosts.

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
- [Den with flakes + flake-parts](https://github.com/vic/vix/tree/befe19da4216f45d82ef15cef4fb98dd0181b1bf)
- [Dendritic flake-parts only](https://github.com/vic/vix/tree/449572c34bda13b3828ea04c03f0fa202f78a763)
- [blueprint](https://github.com/vic/vix/tree/75f1858f6b87b664fedaaedeb08ee924511fcd54)
- [flake-parts](https://github.com/vic/vix/tree/4a3640f97bc5f339ccc4e27071813034c2fd9465)
- other couple made with snowfall-lib and [custom-made-libs](https://github.com/vic/mk-darwin-system) lost
