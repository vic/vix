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
├── dendritic.nix      # Bootstraps dendritic libs
├── community/vix.nix  # Creates vix.* namespace
├── hosts.nix          # Declares hosts, wires default profiles
├── community/
│   └── profile.nix    # Defines host-profile and user-profile hooks
├── hosts/
│   └── nargun.nix     # Composes aspects for nargun host
└── vic/
    └── common-host-env.nix  # Composes user environment aspects
```

## Key Patterns

### 1. Custom Namespace ([`vix.nix`](modules/community/vix.nix))
```nix
den.aspects.vix.provides = { }; # you can also use flake.aspects to expose all to flake.modules.
flake.vix = config.den.aspects.vix.provides; # I just want to expose the vix aspect tree.
_module.args.vix = config.den.aspects.vix.provides;
```

Creates `vix.*` namespace. Everything under `vix` belongs to this config.

The `vix` namespace is written to directly, and read from module args, it is also shared as a flake output.
Meaning other people can do `_module.args.vix = inputs.vix.vix`, and re-use modules from this repository's `community/` exactly as they are. Adopting a namespace for your aspects allows re-use for people using import-tree to load files from community repos.



### 2. Central Host Declaration ([`hosts.nix`](modules/hosts.nix))
```nix
den.hosts.x86_64-linux.nargun.users.vic = { };

den.default.host._.host.includes = [ vix.host-profile ];
den.default.user._.user.includes = [ vix.user-profile ];
```
All hosts declared here. Default profiles automatically applied to every host/user.

### 3. Dynamic Profile Routing ([`profile.nix`](modules/community/profile.nix))
```nix
vix.host-profile = { host }: {
  # access host profile from vix, many modules can contribute to the same aspect.
  includes = [ vix.${host.name} ];
};

vix.user-profile = { host, user }: {
  # users can enhance the host they are part of, by providing aspects to it.
  includes = [ (vix.${user.name}._.common-host-env { inherit host user; }) ];
};
```
Profiles select aspects by host/user name. `vix.nargun` wired automatically for nargun host.

### 4. Aspect Composition with Variants ([`nargun.nix`](modules/hosts/nargun.nix))
```nix
vix.nargun.provides = {
  base.includes = [ vix.dev-laptop ];
  hw.includes = [ vix.kvm-amd vix.niri-desktop ];
};

vix.nargun.includes = [ vix.nargun._.base vix.nargun._.hw ];
vix.nargun-vm.includes = [ vix.nargun._.base vix.nargun._.vm ];
```
Sub-aspects via `provides.X` become `_.X`. Hardware and VM share `base`.

### 5. User Environment Assembly ([`common-host-env.nix`](modules/vic/common-host-env.nix))
```nix
vix.vic._.common-host-env = { host, user }: {
  includes = map (f: f { inherit host user; }) [
    vix.vic.provides.admin
    vix.vic.provides.fish
    // ... more aspects
  ];
};
```
User profile calls this with context. Each aspect receives `{ host, user }`.

### 6. Multi-Class Aspects ([`fish.nix`](modules/vic/fish.nix))
```nix
vix.vic.provides.fish = { user, ... }: {
  nixos.users.users.${user.userName}.shell = pkgs.fish;
  homeManager.programs.fish.enable = true;
};
```
Single aspect configures both system and home-manager.

## The Flow

1. **[`dendritic.nix`](modules/dendritic.nix)** loads dendritic libs
2. **[`vix.nix`](modules/vix.nix)** creates namespace (`vix.*`)
3. **[`hosts.nix`](modules/hosts.nix)** declares hosts and wires profiles:
   - `den.hosts.x86_64-linux.nargun.users.vic = { }`
   - Every host includes `vix.host-profile`
   - Every user includes `vix.user-profile`
4. **[`profile.nix`](modules/community/profile.nix)** routes by name:
   - `vix.host-profile` → `vix.${host.name}` (e.g., `vix.nargun`)
   - `vix.user-profile` → `vix.${user.name}._.common-host-env`
5. **[`nargun.nix`](modules/hosts/nargun.nix)** composes host aspects
6. **[`common-host-env.nix`](modules/vic/common-host-env.nix)** composes user aspects

Result: Declare a host in one place, everything wires automatically via naming convention.

## Learning Path

Follow the flow above, then explore:
- **[`fish.nix`](modules/vic/fish.nix)** - Simple parametric aspect
- **[`unfree.nix`](modules/community/unfree.nix)** - Aspect factory pattern
- **[`vm.nix`](modules/vm.nix)** - Package system as VM: `nix run github:vic/vix/den#vm`

## Why Dendritic?


- Named aspects instead of manual imports. 

- Functional Composition instead of Duplication. 

- Parameters intead of Hardcoding.

- Sharing instead of Copy+Pasting.
