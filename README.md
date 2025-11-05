# vix - Vic's Nix Environment - and dendritic example repo.

My repo serves as an educational example showing how [den](https://github.com/vic/den) and my related [libs](https://vic.github.io/dendrix/Dendritic-Ecosystem.html#vics-dendritic-libraries) structure a [Dendritic](https://vic.github.io/dendrix/Dendritic.html) NixOS setup with **named, composable aspects** instead of file imports. This is just one of many possible ways to organize a dendritic implementation. Feel free to explore, and share how you do things.

This specific setup is powered by **[den](https://github.com/vic/den) · [flake-aspects](https://github.com/vic/flake-aspects) · [denful](https://github.com/vic/denful) · [flake-file](https://github.com/vic/flake-file) · [import-tree](https://github.com/vic/import-tree) · [flake-parts](https://github.com/hercules-ci/flake-parts)**

--

## Aspects vs Imports

```nix
# Traditional imports          # Dendritic aspects
imports = [                    vix.nargun.includes = [
  ./hardware.nix                 vix.hardware
  ../../shared/desktop.nix       vix.niri-desktop
];                             ];
```

Aspects are named values, not file paths. They compose without relative path juggling.

## How It's Wired

```
modules/
├── dendritic.nix        # Bootstraps dendritic libs
├── namespace.nix        # Creates `vix`, `vic`, `my` namespaces.
├── my/                  # Infra related aspects
│   |── hosts.nix        # Declares hosts, wires default profiles
│   |── user.nix         # Composes aspect used across all hosts.
│   └── workstation.nix  # Composes host setup.
├── vic/                 # User aspects and user settings.
│   └── *.nix            # many home-manager and os-config from vic.
└── community/vix/       # Community shared aspects
    └── *.nix            # Exposed at flake.denful.vix
```
