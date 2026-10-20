# readme tour: a guided walk of the Ren scope tree with real vix names.
''
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
  `ren.aspects.vic-headless` is every scope where vic lives. `ren.aspects.vic-gui` is graphical machines only.
  ```nix
  ren.aspects.direnv = { at = ren.aspects.vic-headless; homeManager.programs.direnv.enable = true; };
  ```

  **Channels.** A feature emits data. One consumer writes it.
  A feature says `git-ignores = _: [ ".claude" ];` and `git` writes the global ignores.
  Dots, secrets, unfree names and env-packages work the same way.

  **Classes.** Every other aspect key names a module system:
  `nixos`, `darwin`, `homeManager`, `homeLinux`, `homeDarwin`, `account`, `os`, `vim`, `files`.
  A class turns the collected modules into a flake output.
''
