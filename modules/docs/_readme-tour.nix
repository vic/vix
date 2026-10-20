# readme tour: each Ren keyword once, and what vix does with it.
''
  ## A tour

  | Ren | in vix |
  | --- | --- |
  | `ren.kinds.<k>` | typed data: `host`, `mac`, `home`, `user`, `env`, `vim`, `secret`, `ssh-host` |
  | `ren.<k>.<name>` | an instance: `ren.host.frodo`, `ren.user.vic`, `ren.env.rustenv` |
  | `below`, `spawns` | the scope tree: `fleet` → `host` → `guest`, `user`; `system` → `vim`, `env` |
  | `is` | subkinds: `host` and `mac` are a `machine`; `guest` is a `host` |
  | `ren.aspects.<a>` | one feature: `git`, `kvm-amd`, `vic-gui` |
  | `at` | where an aspect is on: `at = ren.aspects.vic-headless` |
  | `includes`, `excludes` | add or drop aspects below a scope: `frodo` includes its hardware; frodo's guests exclude it |
  | `ren.classes.<c>` | a module system an aspect key feeds: `nixos`, `darwin`, `homeManager`, `account`, `vim`, `files` |
  | `into` | how a class builds: `nixos` gives `nixosConfigurations.<host>` |
  | `ren.channels.<c>` | data a feature emits for a receiver: `git-ignores`, `dots`, `secrets`, `checks` |
  | `fold`, `to` | how a channel merges, and who reads it: `checks` folds `attrs` into the fleet |
  | `and`, `anyOf`, `not`, `within`, `has`, `when` | predicates for `at` and `to`: `and [ ren.kinds.host (when (s: s.host.cpu == "amd")) ]` |
  | `same` | identity: a guest runs on the host it names in `on` |
''
