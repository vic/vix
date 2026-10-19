# vix

Vic's machines and homes as one Nix flake: NixOS hosts, nix-darwin macs and
standalone home-manager homes, all built from the same features.
Generated from the live configuration: edit `modules/docs/`, then `nix run .#write-files`.

## How Ren evaluates vix

`outputs = inputs: inputs.ren.lib.mkFlake inputs (inputs.import-tree ./modules);`

1. **Kinds** declare typed data; `ren.<kind>.<name>` are instances.
2. Kinds with `below` form a scope tree: the fleet holds systems, hosts, macs and homes;
   systems hold envs; machines and homes hold their users.
3. **Aspects** activate where their `at` predicate holds (`and anyOf not when within has`).
4. Each aspect key names a **class** (module config) or a **channel** (data emission).
5. Classes turn collected modules into flake outputs; channels fold emissions to receivers.

```nix
ren.host.frodo = { system = ren.system.x86_64-linux; users = [ ren.user.vic ]; form = "laptop"; };
ren.aspects.direnv = {
  at = vicAt.headless; # every scope where user vic lives
  homeManager.programs.direnv.enable = true;
};
```

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

181 aspects live under `modules/`; `ren.aspects.<name>` each.

## Recipes

Every `.nix` under `modules/` is a module (import-tree); paths with `/_` are skipped.

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
# CI matrix: every nixos host, evaluated
for h in $(nix eval --raw .#nixosConfigurations --apply 'c: toString (builtins.attrNames c)'); do
  nix eval --raw ".#nixosConfigurations.$h.config.system.build.toplevel.drvPath"
done
```
