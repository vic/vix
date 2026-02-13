# vix - Vic's Nix Environment

Made [without flakes](https://github.com/vic/flake-file/blob/main/templates/unflake) using my [Dendritic libs](https://dendrix.oeiuwq.com/Dendritic-Ecosystem.html#vics-dendritic-libraries).

Inputs are defined as `flake-file.inputs` options and pinned via [unflake](https://codeberg.org/goldstein/unflake).

## Hosts

Defined at [hosts.nix](modules/hosts.nix).

Currently only [`nargun`](modules/hosts/nargun), others will be ported soon.

## Users

Currently only [`vic`](modules/users/vic) which is applied at all hosts.

## Devshell

Load [shell.nix](shell.nix) using direnv `.envrc` or manually `nix-shell`.

```bash
# .envrc
use nix
```

Useful commands defined at [modules/](modules/devshell.nix)

```bash
write-npins # updates npins from flake-file.inputs definitions using unflake.

write-unflake # used by write-npins like: `write-unflake --backend npins`
write-inputs  # only needed for debugging inputs.nix given to unflake.

os switch nargun # builds nixos generation using nh.
facter nargun    # generates hardware and copies to hosts/<host>/facter.json
```


----

Historical points of this repo:

- [Den without flakes](https://github.com/vic/vix/tree/unflake) **current**
- [Den with flakes + flake-parts](https://github.com/vic/vix/tree/befe19da4216f45d82ef15cef4fb98dd0181b1bf)
- [Dendritic flake-parts only](https://github.com/vic/vix/tree/449572c34bda13b3828ea04c03f0fa202f78a763)
- [blueprint](https://github.com/vic/vix/tree/75f1858f6b87b664fedaaedeb08ee924511fcd54)
- [flake-parts](https://github.com/vic/vix/tree/4a3640f97bc5f339ccc4e27071813034c2fd9465)
- other couple made with snowfall-lib and [custom-made-libs](https://github.com/vic/mk-darwin-system) lost
