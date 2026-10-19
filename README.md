# vix

Vic's machines, homes and dev envs, written in [Ren](https://github.com/vic/ren) (built on Gen).
This file is generated. Edit `modules/docs/`, then run `nix run .#write-files`.

## A tour

Ren holds typed data in **kinds**. Kinds with `below` form a **scope tree**.
Each step below goes one level down. Names are real.

**The fleet.** `ren.fleet.vix` is the root. Everything lives below it.

**Systems.** `x86_64-linux`, `aarch64-darwin` and two more. Each machine, home and env is built for one.

**Machines.** A machine is abstract: it holds typed facts. There are three kinds of it:
`host` (NixOS), `mac` (nix-darwin) and `guest` (a microvm on a host).
Community aspects key on the facts. Say `cpu = "amd"` and the kvm-amd module comes in.
```nix
ren.host.frodo = { system = ren.system.x86_64-linux; users = [ ren.user.vic ]; form = "laptop"; desktops = [ "niri" ]; };
```

**Users.** `ren.user.vic` is a person: name, email, shell. A machine lists its users.
Each listed user becomes a scope below that machine.

**Homes and guests.** `bitstream` and `nargun` are standalone homes of vic: no OS, only home-manager.
`gen` and `dnx` are guests of frodo: one claude microvm for each `ren.workspace`.

**Profiles and envs.** Below each system live the vim profiles (`nvim`, `lazyvim`, ...) and the dev envs (`rustenv`, `goenv`, ...).
A profile builds one neovim. An env builds a devshell. Machines list the envs their users get.

**Aspects.** An aspect is a bundle of config. Its `at` says where it is active.
`vicAt.headless` means every scope where vic lives. `vicAt.gui` means graphical machines only.
```nix
ren.aspects.direnv = { at = vicAt.headless; homeManager.programs.direnv.enable = true; };
```

**Channels.** A feature emits data. One consumer writes it.
A feature says `git-ignores = _: [ ".claude" ];` and `git` writes the global ignores.
Dots, secrets, unfree names and env-packages work the same way.

**Classes.** Every other aspect key names a module system:
`nixos`, `darwin`, `homeManager`, `homeLinux`, `homeDarwin`, `account`, `os`, `vim`, `files`.
A class turns the collected modules into a flake output.

## Vix vocabulary

### Kinds: typed data; a kind some `below` lists gets one scope per instance

| kind | what it is | instances (`ren.<kind>.<name>`) |
| --- | --- | --- |
| `channel` | the nixpkgs, home-manager and nix-darwin pins a machine builds with | unstable |
| `emacs` | an emacs distribution (data only, no scopes) | doom, spc |
| `env` | a dev environment: langs become a devshell and user packages | fullenv, goenv, nixenv, nodeenv, pyenv, rustenv |
| `fleet` | root scope; everything lives below it | vix |
| `guest` | a microvm on a host (is host): its own nixos and users, built inside the host | dnx, gen |
| `home` | a standalone home-manager home of one user | bitstream, nargun |
| `host` | a NixOS machine (is machine) | annatar, bill, bombadil, frodo, mordor, nargun, nienna, smaug, tom |
| `mac` | a nix-darwin machine (is machine) | bert, varda, yavanna |
| `machine` | abstract: typed facts (cpu, form, desktops, users, envs) hosts and macs share | - (abstract) |
| `secret` | a sops secret a feature asks for | anthropic-api-key, copilot-api-key, edge-token, gemini-eco-key, groq-api-key, hello, openrouter-api-key, ssh-conf, ssh-id-ed25519, ssh-localhost-run |
| `ssh-host` | one ssh client matchBlock | edge, sini, uptermd.upterm.dev, vini, vini-tunnel |
| `system` | a nix system; machines, homes and envs are built for one | aarch64-darwin, aarch64-linux, x86_64-darwin, x86_64-linux |
| `user` | a person: full name, email, login shell, admin | vic |
| `vim` | a neovim profile: a feature list built per system into one nvf package (+ a gui wrapper) | astrovim, lazyvim, neovim, nvim, vscode-vim |
| `workspace` | a project an isolated claude guest works on (data): repo path; one guest each | dnx, gen |

### Classes: module systems an aspect key names

| class | builds |
| --- | --- |
| `account` | `users.users.<user>` on the user's machine |
| `darwin` | `darwinConfigurations.<mac>` |
| `files` | repo files (this README): `packages.write-files` + `checks` |
| `homeDarwin` | homeManager on darwin only |
| `homeLinux` | homeManager on linux only |
| `homeManager` | a user's home: on a host, on a mac, or `homeConfigurations.<user>@<home>` |
| `nixos` | `nixosConfigurations.<host>` |
| `os` | either OS: forwards to nixos or darwin |
| `vim` | nvf: one neovim per vim profile, emitted as packages.<profile> |

### Channels: data an aspect key emits and a receiver folds

| channel | emitted by | received by |
| --- | --- | --- |
| `checks` | formatter (fmt), files (README), no-gui (headless homes and guests) | flake `checks.<sys>.<name>` |
| `ci-jobs` | every buildable host, mac, home and linux devshell | flake `ci.matrix`: one GitHub build job each |
| `claude-allow` | user features | `ai-claude` settings.json permissions |
| `devshells` | the `devshell` aspect, per env | flake `devShells.<sys>` |
| `dots` | user features: `{ "<home path>" = "<dots path>"; }` | `vic-dots`: links into $HOME |
| `env-packages` | `env-<lang>` aspects | the env's devshell, and users whose machine lists the env |
| `fish-functions` | user features | `fish` writes them once |
| `formatter` | each system (treefmt) | flake `formatter.<sys>` (`nix fmt`) |
| `git-ignores` | user features | `git` global ignores |
| `login-shells` | users with a shell | their machine enables `programs.<shell>` |
| `packages` | aspects at a system | flake `packages.<sys>`, read back as `self'.packages` |
| `secrets` | user features: `[ ren.secret.x ]` | `vic-secrets`: sops-nix config |
| `unfree` | any scope: `allowUnfree [ … ]` | the machine or home's `allowUnfreePredicate` |

### vic profiles: `at = vicAt.<tier>` gates vic's features; roles are aspects machines include or derive

| name | active |
| --- | --- |
| `vicAt.full` | not on iso images (not within `installer`) |
| `vicAt.gui` | within `graphical`: every gui program lives here |
| `vicAt.headless` | everywhere vic lives: terminal tools only (homes, guests, servers) |
| `vicAt.secrets` | within `trusted` |
| role `graphical` | hosts with desktops or wsl, workstation macs (from facts) |
| role `installer` | iso hosts (from facts) |
| role `live-dots` | included by a machine: dotfiles link live into ~/.flake |
| role `trusted` | included by a machine: holds vic's secrets |

183 aspects live under `modules/`; `ren.aspects.<name>` each.

## Directory structure

import-tree loads every `.nix` file under `modules/`. Paths with `/_` are skipped.
Dir names are for humans only. Ren does not read them.

| dir | purpose |
| --- | --- |
| `modules/community/` | shared hardware and desktop aspects; they key on machine facts |
| `modules/docs/` | this README: generators, vocabulary, recipes |
| `modules/editors/` | vim profiles (nvf) and emacs distributions |
| `modules/envs/` | dev environments and one aspect per language |
| `modules/features/` | flake plumbing: ci, checks, formatter, packages, unfree, accounts |
| `modules/homes/` | standalone home-manager homes |
| `modules/hosts/` | NixOS and darwin machines, and frodo's guests |
| `modules/net/` | ssh hosts and remote desktop |
| `modules/packages/` | own packages and scripts |
| `modules/people/` | users, and the vicAt feature tiers |
| `modules/platforms/` | channels (nixpkgs pins) and how machines are built |
| `modules/security/` | secrets declared as data |
| `modules/topology/` | kinds and the scope tree: fleet, machines, users |
| `modules/vic/` | vic's own features, by area (below) |

Inside `modules/vic/`:

| dir | purpose |
| --- | --- |
| `modules/vic/ai/` | claude, agents, mcp servers, skills |
| `modules/vic/dev/` | dev tools and security ops |
| `modules/vic/dots/` | dotfiles linked into $HOME |
| `modules/vic/edit/` | browsers, editors and terminals |
| `modules/vic/nvf/` | neovim features, one file each |
| `modules/vic/secrets/` | sops setup for vic's secrets |
| `modules/vic/shell/` | fish and shell tools |
| `modules/vic/sys/` | fonts, ssh and system bits |
| `modules/vic/vcs/` | git and jujutsu |

## Recipes

Every `.nix` under `modules/` is a module.

**Add a host**: facts only; community aspects key on them (`modules/hosts/<name>.nix`).
```nix
ren.host.nargun = {
  system = ren.system.x86_64-linux;
  users = [ ren.user.vic ];
  workstation = true;
  cpu = "amd";
  desktops = [ "kde" "niri" ];
};
```

**Add a user feature**: one aspect, gated by a tier (`modules/vic/<area>/<name>.nix`).
```nix
ren.aspects.dev-tools = {
  at = vicAt.full;
  homeManager = { pkgs, ... }: { home.packages = [ pkgs.gh pkgs.jq ]; };
};
```

**Add a dev env**: an instance, then list it on a machine or home (`envs = [ ren.env.goenv ];`).
```nix
ren.env.goenv.langs = [ "go" ];
ren.aspects.env-go = {
  at = ren.lib.and [ ren.kinds.env (ren.lib.when (s: builtins.elem "go" s.env.langs)) ];
  env-packages = { system, ... }: [ (pkgsFor system).go ];
};
```

**Add an ssh host**: one instance becomes one `programs.ssh` matchBlock (`modules/net/ssh-host.nix`).
```nix
ren.ssh-host.edge = {
  host = "edge";
  hostname = "192.168.192.168";
};
```

**Add a secret**: declare it, then emit it from the feature that reads it.
```nix
ren.secret.groq-api-key.sopsKey = "groq_api_key";  # modules/security/secret.nix
ren.aspects.my-feature.secrets = { ... }: [ ren.secret.groq-api-key ];
```

## Commands

```sh
nix build .#nixosConfigurations.frodo.config.system.build.toplevel
nix build '.#homeConfigurations."vic@bitstream".activationPackage'
nix run .#write-files                 # regenerate this README
nix flake check                       # includes checks.x86_64-linux."files/README.md"
nix eval --json .#ci.matrix              # every CI build job: host, mac, home, devshell
```

## History

- Ren (current): this tree, branch `ren` — https://github.com/vic/vix/tree/ren
- [Den without flakes (last Den commit)](https://github.com/vic/vix/tree/historic/den)
- [Den with flakes + flake-parts](https://github.com/vic/vix/tree/historic/den-flake-parts)
- [Dendritic flake-parts only](https://github.com/vic/vix/tree/historic/dendritic-flake-parts)
- [blueprint](https://github.com/vic/vix/tree/historic/blueprint)
- [flake-parts](https://github.com/vic/vix/tree/historic/flake-parts)
- [old m1 flake](https://github.com/vic/vix/tree/historic/mk-darwin-system) with [mk-darwin-system](https://github.com/vic/mk-darwin-system)
- other with snowfall-lib lost
