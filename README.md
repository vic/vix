# Vic's Nix Environment

## Bootstrapping 

### Installing NixOS (Boot from Bombadil USB)

TODO: Automate this on Bombadil USB (Issue [#75](issues/75))

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

TODO: Generate WSL2 tarball (Issue [#83](issues/83))

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

## Hosts

Defined at [`/hosts`](tree/main/hosts) directory.

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
