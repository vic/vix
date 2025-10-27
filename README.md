# vix - A Dendritic NixOS Configuration

A complete example of the **dendritic pattern** for NixOS, using [den](https://github.com/vic/den) to achieve composable, aspect-oriented system configuration.

This repository demonstrates how to structure a real-world NixOS setup using:
- [den](https://github.com/vic/den) - Dendritic configuration framework
- [flake-aspects](https://github.com/vic/flake-aspects) - Aspect-oriented programming for Nix
- [flake-file](https://github.com/vic/flake-file) - Auto-generated flake management
- [import-tree](https://github.com/vic/import-tree) - Automatic module discovery

## Try It Out

Experience the dendritic pattern immediately:
```bash
nix run github:vic/vix/den#vm
```

This launches a VM configured with the same dendritic structure as the production system.

## Understanding the Dendritic Structure

### 🎯 Core Concept: Aspects Over Modules

Traditional NixOS configurations use modules that get imported into a monolithic tree. The dendritic pattern uses **aspects**—named, composable units that can be mixed and matched without creating deep import hierarchies.

### 📁 Repository Structure

```
modules/
├── dendritic.nix          # Entry point: initializes dendritic setup
├── vix.nix                # Custom aspect namespace
├── hosts.nix              # Host declarations & default profiles
├── vm.nix                 # VM launcher for development
│
├── community/             # Reusable aspects (candidate for upstreaming)
│   ├── profile.nix        # Host/user profile hooks
│   ├── unfree.nix         # Aspect for unfree packages
│   ├── autologin.nix      # Parametric autologin aspect
│   ├── *-desktop.nix      # Desktop environment aspects
│   └── dev-laptop.nix     # Composed laptop aspect
│
├── vic/                   # User-specific aspects
│   ├── common-host-env.nix    # User environment composition
│   ├── admin.nix              # User permissions aspect
│   ├── fish.nix               # Shell configuration aspect
│   ├── dots.nix               # Dotfile management aspect
│   └── *.nix                  # Individual feature aspects
│
└── hosts/
    └── nargun.nix         # Host-specific aspect composition with vm variant.
```

## Key Benefits of This Structure

### 1. **Namespace Isolation** ([`vix.nix`](modules/vix.nix))

Created my own aspect namespace without polluting the global scope:

```nix
#  vix is actually: den.aspects.vix.provides.
{ vix, ... }: { # read access
  vix.gaming = ...; # write access
}
```

**Benefit**: All my aspects live under `vix.*`, making it clear what's yours vs. what comes from den or other sources.

### 2. **Declarative Host Registration** ([`hosts.nix`](modules/hosts.nix))

Declare hosts and users in one place:

```nix
den.hosts.x86_64-linux.nargun.users.vic = { };
den.hosts.x86_64-linux.nargun-vm.users.vic = { };
```

**Benefit**: Clear overview of your infrastructure. No hidden host definitions scattered across files.

### 3. **Profile Hooks for Automatic Composition** ([`profile.nix`](modules/community/profile.nix))

Set default includes for all hosts and users:

```nix
den.default.host._.host.includes = [
  vix.host-profile
  den.home-manager
];

den.default.user._.user.includes = [
  vix.user-profile
];
```

**Benefit**: Every host/user automatically gets base configuration without manual wiring. Add once, applies everywhere.

### 4. **Parametric Aspects** ([`profile.nix`](modules/community/profile.nix))

Profiles can dynamically select aspects based on host/user names:

```nix
vix.host-profile = { host }: {
  includes = [
    (vix.${host.name} or { })      # Host-specific if exists
    (vix.host-name host)            # Parametric hostname setter
    vix.state-version               # Common to all hosts
  ];
};
```

**Benefit**: Generic code that adapts to context. No hardcoded names, fully reusable.

### 5. **Aspect Composition** ([`nargun.nix`](modules/hosts/nargun.nix))

Hosts are built by composing aspects:

```nix
vix.nargun.includes = [
  vix.nargun._.base
  vix.nargun._.hw
];

vix.nargun.provides = {
  hw.includes = [
    vix.mexico          # Locale configuration
    vix.bootable        # Boot loader setup
    vix.kvm-amd         # Virtualization support
    vix.niri-desktop    # Window manager
    vix.kde-desktop     # Fallback desktop
  ];

  base.includes = [
    vix.dev-laptop      # Common laptop features
  ];
};
```

**Benefit**: 
- Mix hardware configs, desktops, and features freely
- Share common setups between real hardware and VM
- Easy to see what a host includes at a glance

### 6. **Shared Configuration Between Host Variants** ([`nargun.nix`](modules/hosts/nargun.nix))

Production and VM hosts share a base:

```nix
vix.nargun-vm.includes = [
  vix.nargun._.base     # Shared configuration
  vix.nargun._.vm       # VM-specific overrides
];
```

**Benefit**: Test your actual configuration in a VM with minimal differences. No "works on my VM" problems.

### 7. **Hierarchical Aspect Organization** ([`nargun.nix`](modules/hosts/nargun.nix))

Use `provides` to create sub-aspects:

```nix
vix.nargun.provides = {
  base.includes = [...];    # vix.nargun._.base
  hw.includes = [...];      # vix.nargun._.hw
  vm.includes = [...];      # vix.nargun._.vm
};
```

**Benefit**: Organize related configuration without creating separate files. The `_` makes sub-aspects non-recursive.

### 8. **User Environment Composition** ([`common-host-env.nix`](modules/vic/common-host-env.nix))

Compose user environments from small, focused aspects:

```nix
vix.vic._.common-host-env = { host, user }: {
  includes = map (f: f { inherit host user; }) [
    vix.vic.provides.admin
    vix.vic.provides.fish
    vix.vic.provides.terminals
    vix.vic.provides.editors
    vix.vic.provides.doom-btw
    vix.vic.provides.vim-btw
    // ... more aspects
  ];
};
```

**Benefit**: 
- Each aspect is small, testable, focused
- Easy to enable/disable features
- Functions receive context (`host`, `user`) for parametric behavior

### 9. **Parametric, Generic Aspects** ([`admin.nix`](modules/vic/admin.nix), [`fish.nix`](modules/vic/fish.nix))

Aspects accept parameters instead of hardcoding values:

```nix
# admin.nix
vix.vic.provides.admin = { user, ... }: {
  nixos.users.users.${user.userName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
};

# fish.nix
vix.vic.provides.fish = { user, ... }: {
  nixos.users.users.${user.userName}.shell = pkgs.fish;
  homeManager.programs.fish.enable = true;
};
```

**Benefit**: Aspects are reusable across different users/hosts. Change username once in host declaration, everything updates.

### 10. **Multi-Class Aspects** ([`fish.nix`](modules/vic/fish.nix))

Single aspect can configure multiple "classes" (nixos, homeManager, darwin, etc.):

```nix
vix.vic.provides.fish = { user, ... }: {
  nixos = { pkgs, ... }: {
    programs.fish.enable = true;
    users.users.${user.userName}.shell = pkgs.fish;
  };

  homeManager = {
    programs.fish.enable = true;
  };
};
```

**Benefit**: Related configuration stays together. System-level and user-level config for one feature in one file.

### 11. **Reusable Community Aspects** ([`modules/community/`](modules/community/))

Structure promotes sharing:

```
community/
├── profile.nix       # Integration hooks
├── unfree.nix        # Unfree package handling
├── autologin.nix     # Parametric autologin
├── *-desktop.nix     # Desktop environments
└── dev-laptop.nix    # Feature compositions
```

**Benefit**: 
- Clear separation of reusable vs. personal
- Easy to upstream to [denful](https://github.com/vic/denful)
- Stop copy-pasting, start sharing

### 12. **Functional Aspects with Parameters** ([`unfree.nix`](modules/community/unfree.nix))

Aspects can be functions that return aspects:

```nix
vix.unfree = allowed-names: {
  __functor = _: { class, aspect-chain }: {
    ${class}.nixpkgs.config.allowUnfreePredicate = 
      pkg: builtins.elem (lib.getName pkg) allowed-names;
  };
};

# Usage:
vix.vic.provides.editors.includes = [
  (vix.unfree [ "cursor" "vscode" ])
];
```

**Benefit**: Create aspect factories. Same pattern, different parameters. No duplication.

### 13. **Development Workflow with VM** ([`vm.nix`](modules/vm.nix))

Package your system as a runnable VM:

```nix
packages.vm = pkgs.writeShellApplication {
  name = "vm";
  text = ''
    ${inputs.self.nixosConfigurations.nargun-vm.config.system.build.vm}/bin/run-nargun-vm-vm "$@"
  '';
};
```

**Benefit**: 
- Test configuration changes without rebooting
- Share exact system state with others via `nix run`
- Rapid iteration during development

### 14. **Smart Dotfile Management** ([`dots.nix`](modules/vic/dots.nix))

Out-of-store symlinks for live editing:

```nix
dotsLink = path:
  config.lib.file.mkOutOfStoreSymlink 
    "${config.home.homeDirectory}/.flake/modules/vic/dots/${path}";

home.file.".config/nvim".source = dotsLink "config/nvim";
```

**Benefit**: Edit dotfiles directly, changes reflect immediately without rebuilding. Best of both worlds.

## Getting Started with Dendritic

### 1. Bootstrap from Template

```bash
nix flake init -t github:vic/flake-file#dendritic
nix flake update
```

This creates:
- [`modules/dendritic.nix`](modules/dendritic.nix) - Den initialization
- Basic structure following the pattern

### 2. Create Your Namespace ([`vix.nix`](modules/vix.nix))

```nix
{ config, lib, ... }:
{
  den.aspects.myname.provides = { };
  _module.args.myname = config.den.aspects.myname.provides;
  flake.myname = config.den.aspects.myname.provides;
  imports = [ (lib.mkAliasOptionModule [ "myname" ] [ "den" "aspects" "myname" "provides" ]) ];
}
```

### 3. Register Hosts ([`hosts.nix`](modules/hosts.nix))

```nix
{ myname, den, ... }:
{
  den.hosts.x86_64-linux.myhost.users.myuser = { };

  den.default.host._.host.includes = [
    myname.host-profile
    den.home-manager
  ];

  den.default.user._.user.includes = [
    myname.user-profile
  ];
}
```

### 4. Create Profile Hooks (see [`profile.nix`](modules/community/profile.nix))

```nix
myname.host-profile = { host }: {
  includes = [
    (myname.${host.name} or { })
    myname.state-version
  ];
};

myname.user-profile = { host, user }: {
  includes = [
    ((myname.${user.name}._.common-host-env or (_: { })) { inherit host user; })
  ];
};
```

### 5. Define Host Aspects (see [`nargun.nix`](modules/hosts/nargun.nix))

```nix
{ myname, ... }:
{
  myname.myhost.includes = [
    myname.bootable
    myname.networking
    myname.my-desktop
  ];
}
```

### 6. Build User Environment (see [`common-host-env.nix`](modules/vic/common-host-env.nix))

```nix
myname.myuser._.common-host-env = { host, user }: {
  includes = map (f: f { inherit host user; }) [
    myname.myuser.provides.admin
    myname.myuser.provides.shell
    myname.myuser.provides.editor
  ];
};
```

## Design Principles

### Aspect Composition Over Module Imports

**Traditional NixOS:**
```nix
imports = [
  ./hardware.nix
  ./networking.nix
  ./desktop.nix
  ./users/vic.nix
];
```

**Dendritic Pattern:**
```nix
vix.nargun.includes = [
  vix.hardware
  vix.networking
  vix.desktop
];
```

Benefits:
- Aspects are named and first-class
- Can be referenced, composed, and parameterized
- No relative path management
- Clear dependency relationships

### Parametric by Default

All aspects should accept `{ host, user }` when relevant:

```nix
# ❌ Hardcoded
vix.vic.admin.nixos.users.users.vic = { ... };

# ✅ Parametric
vix.vic.provides.admin = { user, ... }: {
  nixos.users.users.${user.userName} = { ... };
};
```

### Separate Personal from Shareable

- `modules/community/` - Reusable, generic, upstreamable
- `modules/{yourname}/` - Personal, specific to your needs
- `modules/hosts/` - Host-specific configuration

When something in your personal namespace becomes useful, move it to `community/` and consider upstreaming to [denful](https://github.com/vic/denful).

## Learning Path

Follow this sequence to understand the pattern:

1. **[`dendritic.nix`](modules/dendritic.nix)** - How den is initialized
2. **[`vix.nix`](modules/vix.nix)** - Creating a custom namespace
3. **[`hosts.nix`](modules/hosts.nix)** - Host registration and default hooks
4. **[`profile.nix`](modules/community/profile.nix)** - Profile system for automatic composition
5. **[`nargun.nix`](modules/hosts/nargun.nix)** - Host aspect composition example
6. **[`common-host-env.nix`](modules/vic/common-host-env.nix)** - User environment composition
7. **[`admin.nix`](modules/vic/admin.nix)**, **[`fish.nix`](modules/vic/fish.nix)** - Simple parametric aspects
8. **[`unfree.nix`](modules/community/unfree.nix)** - Advanced: functional aspects
9. **[`vm.nix`](modules/vm.nix)** - Development workflow

## Contributing to the Dendritic Ecosystem

Found something useful in this repo? Instead of copy-pasting:

1. Move it to `modules/community/` if it's not already there
2. Make it parametric and generic
3. Open an issue to discuss upstreaming to [denful](https://github.com/vic/denful)

The goal is to build a library of well-maintained, composable aspects that everyone can benefit from.

## Migration Notes

This repository represents a complete rewrite of vix using the dendritic pattern. The old monolithic approach is preserved in the `main` branch for reference.

**Development workflow:** Boot from stable `main` branch, edit this `den` branch, test changes via `nix run .#vm` without rebooting.

## Why Dendritic?

Traditional NixOS configurations grow into tangled import trees. You end up with:
- Deep hierarchies hard to navigate
- Unclear dependencies
- Difficulty reusing configuration
- Copy-paste proliferation

The dendritic pattern solves this by:
- **Named aspects** instead of file paths
- **Composition** instead of inheritance
- **Parameters** instead of hardcoded values
- **Namespaces** instead of global scope
- **Automatic discovery** via import-tree
- **First-class functions** for aspect factories

The result: configuration that's easier to understand, modify, test, and share.

---

**See also:** [den documentation](https://github.com/vic/den), [flake-aspects](https://github.com/vic/flake-aspects), [denful](https://github.com/vic/denful)