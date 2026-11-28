# Architecture pages: Overview, Roles & Tiers, Kits & Boundaries.
{ yen, ... }:
let
  b = builtins;
  d = yen.helpers.vixDocs;

  allHosts = {
    instances = yen.kinds.host;
  };
  allMacs = {
    instances = yen.kinds.mac;
  };
  allHomes = {
    instances = yen.kinds.home;
  };
in
{
  yen.docPage.overview = {
    title = "Architecture Overview";
    section = yen.docSection.architecture;
    order = 10;
    badge = "start here";
    summary = "How Vix separates typed fleet facts from platform wiring and user features using one Yen scope tree.";
  };

  yen.aspects.doc-arch-overview = {
    at = yen.docPage.overview;
    cycle =
      { tree, ... }:
      (nHosts: nMacs: nHomes: {
        tree = [
          allHosts
          allMacs
          allHomes
        ];
        docBody = ''
          A growing NixOS repository usually tangles machine data, `specialArgs`, and Home Manager wiring together.
          Vix avoids that glue by splitting the fleet into small decoupled layers loaded directly by `inputs.yen.mkFlake`.

          ${d.mermaid ''
            flowchart TD
              root["root (flake outputs + .#yen)"]
              sys["system (x86_64-linux, aarch64-linux, aarch64-darwin)"]
              host["host (${toString nHosts} NixOS machines)"]
              mac["mac (${toString nMacs} nix-darwin machines)"]
              home["home (${toString nHomes} standalone homes, wall = true)"]
              user["user (vic)"]
              guest["guest (MicroVM)"]
              env["env (6 devShells)"]
              vim["vim (5 NVF profiles)"]

              root --> sys
              root --> host
              root --> mac
              root --> home
              sys --> env
              sys --> vim
              host --> user
              host --> guest
              host --> home
              mac --> user
              home --> user
              user --> env
          ''}

          ## Kind inheritance via `extends`

          Instead of duplicating fields and sinks across NixOS hosts, MicroVM guests, macOS machines, and standalone homes, Vix builds one inheritance chain in `modules/topology/machine.nix`:

          - **`place`** declares `system`, `channel`, `trusted`, and `envs`.
          - **`machine`** extends `place` with `users`, `workstation`, `sharedPkgs`, `impermanence`, and the shared `os` sink.
          - **`linux`** extends `machine` with `nixos` and forwards `os` straight into `nixos`.
          - **`host`** and **`guest`** extend `linux`. **`mac`** extends `machine`, and **`home`** extends `place` with `wall = true`.

          ## Zero string tags anywhere

          Every hardware vendor, form factor, desktop, keyboard layout, language, and Neovim feature is a data-only Yen kind (`yen.cpu.amd`, `yen.gpu.nvidia`, `yen.desktop.niri`, `yen.lang.rust`, `yen.vimFeature.snacks`).
          A typo fails at evaluation time with typo suggestions instead of silently skipping a module.

          ## Directory layout

          ${d.table
            [ "Folder" "Responsibility" ]
            [
              [
                "`modules/topology/`"
                "Scope tree, inheritance (`place`, `machine`), channels, users, secrets, and SSH hosts"
              ]
              [
                "`modules/platforms/`"
                "How NixOS, nix-darwin, Home Manager, MicroVMs, accounts, and ports build flake outputs"
              ]
              [
                "`modules/roles/`"
                "Data-driven roles (`graphical`, `trusted`, `installer`) and feature tiers (`vic-*`)"
              ]
              [
                "`modules/kits/`"
                "Reusable multi-role kits (`github-runner`, `facter`) bound via `yen.assemblies`"
              ]
              [
                "`modules/hosts/`"
                "Tiny fact-only files declaring each machine and standalone home"
              ]
              [
                "`modules/hardware/`, `desktops/`, `forms/`"
                "Decoupled NixOS/Darwin modules matching host facts via `at`"
              ]
              [
                "`modules/envs/`, `editors/`"
                "DevShell environments (`yen.env.*`) and NVF Neovim profiles (`yen.vim.*`)"
              ]
              [
                "`modules/vic/`"
                "Personal features (shell, VCS, editors, AI tools, dev tools) gated by `vic-*` tiers"
              ]
              [
                "`modules/agent/`"
                "Pure-Nix Datalog `yen.relations`, `yen.invariants`, `yen.queries`, and trust `yen.labels`"
              ]
              [
                "`modules/docs/`"
                "Self-documenting fleet pages, `README.md`, and GitHub Pages workflow"
              ]
            ]
          }

          Verify the entire architecture from your shell at any time:

          ${d.sh ''
            nix eval .#yen.ok
            nix eval --json .#yen.schema
          ''}

          Next, see how roles and tiers decouple features from machine names in [Roles & Feature Tiers](/architecture/roles-and-tiers/).
        '';
      })
        (b.length (tree.select allHosts))
        (b.length (tree.select allMacs))
        (b.length (tree.select allHomes));
  };

  yen.docPage.roles-and-tiers = {
    title = "Roles & Feature Tiers";
    section = yen.docSection.architecture;
    order = 20;
    summary = "Decouple personal features from hostnames using pure-Nix Datalog roles and four composable user tiers.";
  };

  yen.aspects.doc-arch-roles = {
    at = yen.docPage.roles-and-tiers;
    docBody = ''
      No feature under `modules/vic/` ever checks a hostname like `"frodo"` or `"varda"`.
      Instead, `modules/roles/roles.nix` derives capabilities from typed facts using ${d.tupu}-inspired Datalog selectors, and `modules/roles/tiers.nix` composes four user tiers on top.

      ${d.file ../roles/roles.nix "modules/roles/roles.nix"}

      ${d.file ../roles/tiers.nix "modules/roles/tiers.nix"}

      ## Why four tiers keep 150+ modules clean

      ${d.table
        [ "Tier aspect" "Where it activates" "What attaches to it" ]
        [
          [
            "`yen.aspects.vic-headless`"
            "Every `vic` scope (hosts, Macs, WSL, ISO, standalone homes)"
            "Shell (`fish`, `direnv`, `carapace`), `git`, `jj`, core CLI tools"
          ]
          [
            "`yen.aspects.vic-full`"
            "`vic-headless` outside ISO installers (`at.not (at.under yen.aspects.installer)`)"
            "Full dev toolchains, editors, AI helpers, and heavier packages"
          ]
          [
            "`yen.aspects.vic-gui`"
            "`vic-headless` under any `graphical` place (`at.nearest yen.kinds.place`)"
            "Browsers, Ghostty/iTerm2 terminals, GUI Neovim wrappers"
          ]
          [
            "`yen.aspects.vic-secrets`"
            "`vic-headless` under any `trusted` place"
            "SOPS-decrypted SSH keys, API keys, and persistent SSH agent config"
          ]
        ]
      }

      Inspect which roles and tiers activated on any machine right from the terminal:

      ${d.sh ''
        nix eval --json .#yen.ask.aspectsOn --apply 'f: f { place = "frodo"; }'
        nix eval --json .#yen.explain --apply 'f: f "vic-gui" "host:frodo/user:vic"'
      ''}

      Next, explore Vix's kits, walled standalone homes, and reactive boundaries in [Kits, Walls & Reactive Boundaries](/architecture/kits-and-boundaries/).
    '';
  };

  yen.docPage.kits-and-boundaries = {
    title = "Kits, Walls & Reactive Boundaries";
    section = yen.docSection.architecture;
    order = 30;
    summary = "Wire GitHub runners and facter reports with `yen.kits`, isolate standalone homes with `wall = true`, and route MicroVMs reactively.";
  };

  yen.aspects.doc-arch-kits = {
    at = yen.docPage.kits-and-boundaries;
    docBody = ''
      ## Native `yen.kits` and `yen.assemblies`

      Vix packages reusable multi-machine patterns as kits so host files stay declarative.

      - **`yen.kits.github-runner`** (`modules/kits/github-runner.nix`): binds bare CI runners (`tom`, `bill`, `bert`). Each runner emits its label to the keyed `runners` sink (`reduce.keyed`), enforcing one runner per system.
      - **`yen.kits.facter`** (`modules/kits/hardware.nix`): binds one `hardware` assembly across every `yen.kinds.host`, wiring `hosts/_facter/<host>.json` into `hardware.facter.reportPath` whenever a report exists.

      ${d.file ../kits/hardware.nix "modules/kits/hardware.nix"}

      ## Walled standalone homes (`wall = true`)

      Standalone Home Manager profiles (`yen.home.nargun` nested under `yen.host.nargun`, and hostless `yen.home.bitstream`) reuse the exact same `modules/vic/` aspects as embedded NixOS homes.
      `yen.kinds.home` sets `wall = true` with an explicit `passUp` list in `modules/platforms/home-manager.nix`.
      OS-level sinks like `nixos` or `account` can never leak upward from a standalone home onto its host.

      ## ${d.cyclejs} reactive networking for MicroVMs

      When a `host` spawns `yen.kinds.guest` MicroVMs, `vm-host` in `modules/platforms/microvm.nix` runs a ${d.cyclejs} `cycle = { tree, ... }:` component.
      It queries `tree.select guests` and generates one routed TAP network per guest automatically.
      A Datalog invariant (`unique-guest-addr`) guarantees no two guests ever claim the same IP.

      ## Opt-in `sharedPkgs` leader/follower deduplication

      Any NixOS hosts with `sharedPkgs = true` in the same `(channel, system)` group elect a deterministic leader and share its evaluated `pkgs` via `readOnlyPkgs`.
      A reactive guard (`shared-pkgs-group`) refuses to build if a follower requests an unfree package its leader does not allow.

      Inspect active kit member scopes directly from the CLI:

      ${d.sh ''
        nix eval --json .#yen.scopes --apply 'xs: builtins.filter (s: s.kind == ["_member"]) xs'
      ''}

      Next, browse the live generated machine catalog in [Machines & Homes](/fleet/machines/).
    '';
  };
}
