# Vic's Nix Environment

[![CI](https://github.com/vic/vix/actions/workflows/build-systems.yaml/badge.svg)](https://github.com/vic/vix/actions/workflows/build-systems.yaml)
[![Cachix](https://img.shields.io/badge/cachix-vix-blue.svg)](https://app.cachix.org/cache/vix)
[![Dendritic Pattern](https://img.shields.io/badge/pattern-dendritic-6c3.svg)](https://vic.github.io/dendrix/Dendritic.html)

Welcome! This repository is vic's, modular, and shareable NixOS/MacOS/WSL configuration, designed both for my own use and as a template for anyone interested in the [Dendritic](https://vic.github.io/dendrix/Dendritic.html) pattern. Whether you're new to Nix or a seasoned user, you'll find reusable modules, clear structure, and plenty of pointers to help you get started or extend your own setup.

---

## Table of Contents

1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Host Configurations](#host-configurations)
4. [Everyday Usage](#everyday-usage)
5. [Shareable Modules & Features](#shareable-modules--features)
   - [Community Modules Overview](#community-modules-overview)
6. [For Contributors](#for-contributors)
7. [Quaerendo Invenietis](#quaerendo-invenietis)
8. [CI & Caching](#ci--caching)
9. [References](#references)

---

## Overview

- **Dendritic Pattern:**  
  This repo uses [`vic/flake-file`](https://github.com/vic/flake-file) to automatically generate `flake.nix` from [inputs defined on modules](https://github.com/search?q=repo%3Avic%2Fvix%20%22flake-file.inputs%22%20language%3ANix&type=code), flattening dependencies for you. The entrypoint is [`modules/flake/dendritic.nix`](modules/flake/dendritic.nix).  
  [`vic/import-tree`](https://github.com/vic/import-tree) then auto-discovers and loads all `./modules/**/*.nix` files, so you can focus on writing modular, reusable code.

- **Modular Structure:**
  - `modules/community/`: Shareable, generic modules and features for any NixOS/Darwin system.
  - `modules/vic/`: Personal, but some modules are reusable (see below).
  - `modules/hosts/`: Per-host configuration (see [osConfigurations.nix](modules/flake/osConfigurations.nix)).

---

## Getting Started

It's easy to get going! Clone the repo, link it, and (optionally) set up secrets:

```fish
git clone https://github.com/vic/vix ~/vix
ln -sfn ~/vix ~/.flake
# (Optional) Setup SOPS keys if using secrets
nix run path:~/vix#vic-sops-get -- --keyservice tcp://SOPS_SERVER:5000 -f SSH_KEY --setup - >> ~/.config/sops/age/keys.txt
```

- **NixOS:**  
  `nixos-install --root /mnt --flake ~/vix#HOST`
- **Darwin/WSL/Ubuntu:**  
  `nix run path:~/vix#os-rebuild -- HOST switch`

---

## Host Configurations

All hosts are defined in [`modules/hosts/`](modules/hosts/), and exposed via [`osConfigurations.nix`](modules/flake/osConfigurations.nix).

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

- **Rebuild any host:**  
  `nix run path:~/vix#os-rebuild -- HOST switch`
- **Rotate secrets:**  
  `nix develop .#nixos -c vic-sops-rotate`

---

## Shareable Modules & Features

This repository is not just for me! Many modules are designed to be reused in your own Nix setups, especially if you want to try the Dendritic pattern. You can browse the [`modules/community/`](https://github.com/vic/vix/tree/main/modules/community) directory, or use the `dendrix.vic-vix` tree in your own flake.

```nix
# Example usage in your own flake
{ inputs, lib, ...}: {
  imports = [
    # Use import-tree's API to select only the files you need
    inputs.dendrix.vic-vix.filter(lib.hasSuffix "xfce-desktop.nix")
  ];
}
```

### Community Modules Overview

#### features/

- **\_macos-keys.nix**: MacOS-specific key management helpers.
- **all-firmware.nix**: Installs all available firmware blobs for broad hardware support.
- **bootable-private.nix**: Example for hiding private files in bootable images.
- **bootable.nix**: Makes a NixOS system image bootable (for ISOs/USB).
- **darwin.nix**: MacOS-specific system settings and tweaks.
- **gnome-desktop.nix**: GNOME desktop environment configuration.
- **kde-desktop.nix**: KDE desktop environment configuration.
- **kvm+amd.nix**: KVM/QEMU virtualization support for AMD CPUs.
- **kvm+intel.nix**: KVM/QEMU virtualization support for Intel CPUs.
- **macos-keys.nix**: (Alias/duplicate) MacOS key management.
- **nix-setttings.nix**: Common Nix settings.
- **nixos.nix**: NixOS-specific system settings.
- **nvidia.nix**: NVIDIA GPU support and configuration.
- **platform.nix**: Platform detection and helpers (Linux, Darwin, WSL, etc).
- **rdesk+inputleap+anydesk.nix**: Remote desktop and input sharing tools.
- **unfree.nix**: Enables unfree packages and related options.
- **wl-broadcom.nix**: Broadcom wireless support for Linux.
- **wsl.nix**: WSL2-specific tweaks and integration.
- **xfce-desktop.nix**: XFCE desktop environment configuration.

#### flake/

- **formatter.nix**: Nix formatter configuration for consistent code style.
- **systems.nix**: Supported system types/architectures for the flake.

#### home/

- **nix-index.nix**: Home-manager integration for `nix-index` (fast file search).
- **nix-registry.nix**: Home-manager integration for Nix registry pinning.
- **vscode-server.nix**: Home-manager config for VSCode server (remote editing).

#### lib/

- **+hosts-by-system.nix**: Utility to group hosts by system type.
- **+mk-os.nix**: Helper for creating OS-specific module sets.
- **+unfree-module.nix**: Helper for enabling unfree modules.
- **option.nix**: Option utilities for Nix modules.

#### packages/

- **+gh-flake-update.nix**: Script to update flake inputs and create a GitHub PR.
- **+os-rebuild.nix**: Universal rebuild script for any host.

---

## For Contributors

- Contributions are accepted mostly for files under `modules/community/`.
- All other modules like `modules/hosts/HOST/`, or `modules/vic` are most
  likely only useful for me, but the most I can move to community the better.
- My hosts are exposed at [`modules/flake/osConfigurations.nix`](modules/flake/osConfigurations.nix).

---

## Quaerendo Invenietis

If you need help with something, just ask. I'll be happy to help.

---

## CI & Caching

- [GitHub Actions](.github/workflows/build-systems.yaml) builds and caches all hosts.
- [Cachix](https://app.cachix.org/cache/vix) used for binary caching.

There's also actions for reminding me to SOP rotate secrets and flake updates.

---

## References

- [Dendritic Pattern](https://github.com/mightyiam/dendritic)
- [vic/flake-file](https://github.com/vic/flake-file)
- [vic/import-tree](https://github.com/vic/import-tree)
- [Dendrix Layers](https://github.com/vic/dendrix)

---

_For more details, see the [modules](modules/) directory and comments in each file._
