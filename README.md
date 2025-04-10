# Vic's Nix Environment

```bash
# previously setup keys for secrets.

git clone git@github.com:vic/vix
cd vix
ln -sfn $PWD $HOME/.flake # Used to link config files (nvim/doom-emacs/terminals,etc)
nix run -- <hostname> <switch | build>
```

## Hosts

Defined at `/hosts` directory.
[CI Workflow](https://github.com/vic/vix/actions/workflows/build-systems.yaml)

### Bombadil - ISO Image - x86_63-linux
USB Bootable
CI: ubuntu-latest
Build: nix build .#.nixosConfigurations.installer.config.system.build.isoImage

### Varda - Darwin - aarm64-darwin
Users: vic
Host: MacMini M4
CI: macos-latest
Build: darwin-rebuild --flake .#varda build

### Yavanna - Darwin - x86_64-darwin
Users: vic
Host: MacBook Pro Late-2011
CI: macos-13
Build: darwin-rebuild --flake .#yavanna build

### Niena - NixOS - x86_64-linux
Users: vic
Host: MacBook Pro Late-2011
CI: ubuntu-latest
Build: nixos-rebuild --flake .#niena build

### Mordor - NixOS - x86_64-linux
Users: vic
Host: ASUS ROG Tower.
CI: ubuntu-latest
Build: nixos-rebuild --flake .#mordor build

### Annatar - Windows WSL2 - x86_64-linux
Users: vic
Host: ASUS ROG Tower.
CI: ubuntu-latest
Build: nixos-rebuild --flake .#annatar build

### Nargun - NixOS - x86-64-linux
Users: vic
Host: Laptop Lenovo
CI: ubuntu-latest
Build: nixos-rebuild --flake .#nargun build

### Smaug - NixOS - x86-64-linux
Users: vic
Host: Laptop HP
CI: ubuntu-latest
Build: nixos-rebuild --flake .#smaug build

### Bill - Ubuntu - aarm64-linux
Users: runner (vic)
Host: GH Action Runner (Upterm + VSCode Remote)
CI: ubuntu-24.04-arm
Build: home-manager --flake .#runner@bill build

### Bert - MacOS - aarm64-darwin
Users: runner (vic)
Host: GH Action Runner (Upterm + VSCode Remote)
CI: macos-latest
Build: home-manager --flake .#runner@bert build

### Tom - Ubuntu - x86_64-linux
Users: runner (vic)
Host: GH Action Runner (Upterm + VSCode Remote)
CI: ubuntu-latest
Build: home-manager --flake .#runner@tom build
