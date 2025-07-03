# Vic's Nix Environment

### [Dendritic](https://github.com/mightyiam/dendritic) setup

My `flake.nix` is auto-generated using [`vic/flake-file`](https://github.com/vic/flake-file).
Particularly, I use the
[`flake-file.flakeModules.dendritic`](https://github.com/vic/flake-file/tree/main/modules/dendritic) module,
by importing it on [modules/flake/dendritic.nix](https://github.com/vic/vix/blob/main/modules/flake/dendritic.nix).

> I'll be moving generic/reusable configurations into [Dennix](https://github.com/vic/dennix) and dogfooding them in here.

My `flake.nix` file serves mainly for listing dependencies and adding nix config and caches.
The entrypoint is `default.nix` which simply uses [vic/import-tree](https://github.com/vic/import-tree) to load all `./modules/**/*.nix` flake-parts modules.

[Hosts](https://github.com/vic/vix/blob/main/modules/hosts) are flake exposed at [osConfigurations.nix](https://github.com/vic/vix/blob/main/modules/flake/osConfigurations.nix). Each host instance loads a `modules.nixos.${hostname}` or `modules.darwin.${hostname}` and I also have base modules for each type of host `modules.nixos.wsl`, `modules.nixos.nixos` and `modules.darwin.darwin`. These can be found under the [features](https://github.com/vic/vix/blob/main/modules/features) directory. Each host particular configuration also mixins some other features as needed.

Most host [include](https://github.com/vic/vix/blob/main/modules/hosts/mordor/configuration.nix) their respective (darwin/nixos) [`vic` user](https://github.com/vic/vix/blob/main/modules/vic/user.nix) configuration module.
My home-managed features are under the [vic](https://github.com/vic/vix/blob/main/modules/vic) directory and they
are mixed automatically under the a single `modules.homeManager.vic`, flake exposed by [vic/home.nix](https://github.com/vic/vix/blob/main/modules/vic/home.nix).

### CI

There's an [action](https://github.com/vic/vix/blob/main/.github/workflows/build-systems.yaml) that [builds each host](https://github.com/vic/vix/actions/workflows/build-systems.yaml) independently pusing builds at vix cachix. so that evaluating later locally will just download those cached derivations.

## Bootstrapping

### Installing NixOS (Boot from Bombadil USB)

TODO: Automate this on Bombadil USB (Issue [#75](https://github.com/vic/vix/issues/75))

```bash
# Edit your partitions.  Mount /mnt/{boot,home,etc}
git clone https://github.com/vic/vix /mnt/home/vic/vix

# Make sure you update hosts/HOST/{filesystems, hardware-configuration}.nix
# To match the current hardware.

# Will be used during home-manager activation, to link .config files.
ln -sfn /home/vic/vix /mnt/home/vic/.flake

# Setup local sops keys via SSH Forwarded SOPS_SERVER.
# You will be prompted for a Password.
nix run path:/mnt/home/vic/vix#vic-sops-get -- \
  --keyservice tcp://SOPS_SERVER:5000 -f SSH_KEY --setup - \
  >> /mnt/home/vic/.config/sops/age/keys.txt

# Finally install nixos
nixos-install --root /mnt --flake /mnt/home/vic/vix#HOST

# You will be prompted for a root password by the installer
# Dont forget to choot and setup password for users.
```

## Installing on Windows-WSL2 (Boot NixOS-WSL2)

TODO: Generate WSL2 tarball (Issue [#83](https://github.com/vic/vix/issues/83))

```
# * import and boot from NixOS-WSL
# * clone, link-flake and setup-sops-keys (see NixOS install)

# apply configuration
nix run path:~/vix#os-rebuild -- HOST switch

# on a windows terminal:
> wsl.exe --terminate NixOS
> wsl.exe -d NixOS
```

## Installing on MacOS

You need nix installed.

We recommend [Lix Installer](https://lix.systems/install/), and
using `install macos --volume-label` if you are using multiple MacOS installations.

```
# * install nix
# * clone, link-flake and setup-sops-keys (see NixOS install)

# apply configuration
nix run path:~/vix#os-rebuild -- HOST switch
```

## Every day usage

```bash
nix run path:~/vix#os-rebuild -- HOST switch
```

## Rotate Secrets

```bash
nix develop .#nixos -c vic-sops-rotate
```

## Hosts

Defined at [`/modules/flake/osConfigurations.nix`](https://github.com/vic/vix/tree/main/modules/flake/osConfigurations.nix).

[![Workflow](https://github.com/vic/vix/actions/workflows/build-systems.yaml/badge.svg)](https://github.com/vic/vix/actions/workflows/build-systems.yaml)

### Bombadil - ISO Image - x86_63-linux

```
USB Bootable
CI: ubuntu-latest
Build: nix build .#.nixosConfigurations.installer.config.system.build.isoImage
```

### Varda - Darwin - aarm64-darwin

```
Users: vic
Host: MacMini M4
CI: macos-latest
Build: darwin-rebuild --flake .#varda build
```

### Yavanna - Darwin - x86_64-darwin

```
Users: vic
Host: MacBook Pro Late-2011
CI: macos-13
Build: darwin-rebuild --flake .#yavanna build
```

### Niena - NixOS - x86_64-linux

```
Users: vic
Host: MacBook Pro Late-2011
CI: ubuntu-latest
Build: nixos-rebuild --flake .#niena build
```

### Mordor - NixOS - x86_64-linux

```
Users: vic
Host: ASUS ROG Tower.
CI: ubuntu-latest
Build: nixos-rebuild --flake .#mordor build
```

### Annatar - Windows WSL2 - x86_64-linux

```
Users: vic
Host: ASUS ROG Tower.
CI: ubuntu-latest
Build: nixos-rebuild --flake .#annatar build
```

### Nargun - NixOS - x86-64-linux

```
Users: vic
Host: Laptop Lenovo
CI: ubuntu-latest
Build: nixos-rebuild --flake .#nargun build
```

### Smaug - NixOS - x86-64-linux

```
Users: vic
Host: Laptop HP
CI: ubuntu-latest
Build: nixos-rebuild --flake .#smaug build
```

### Bill - Ubuntu - aarm64-linux

```
Users: runner (vic)
Host: GH Action Runner (Upterm + VSCode Remote)
CI: ubuntu-24.04-arm
Build: home-manager --flake .#runner@bill build
```

### Bert - MacOS - aarm64-darwin

```
Users: runner (vic)
Host: GH Action Runner (Upterm + VSCode Remote)
CI: macos-latest
Build: home-manager --flake .#runner@bert build
```

### Tom - Ubuntu - x86_64-linux

```
Users: runner (vic)
Host: GH Action Runner (Upterm + VSCode Remote)
CI: ubuntu-latest
Build: home-manager --flake .#runner@tom build
```
