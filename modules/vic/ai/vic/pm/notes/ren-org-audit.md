# Ren organization audit v2: compose with aspects + channels, not checks (2026-10-21, design only)

vic ruling (2026-10-21): do all proposals. Reuse = aspects. Instead of `when` checks, compose via channels and aspect refs.
v2 = full README re-read (~/hk/ren-and-stimpy/README.md, all 642 lines). Nothing evaluated. Implementation goes through team-lead in a jj workspace.

## REN CAPABILITIES THAT REPLACE CHECKS (cited)
- activator: an aspect `at` one instance that `includes` include-only aspects (template hosts/lb.nix:11-17; README:367).
- aspect ref in `at` = "has aspect" (Den hasAspect/includeIf, README:559). Active through includes too; stratified (README:284,293).
- includes act in the aspect's scopes AND subtrees (README:264): a host include reaches its users and guests.
- a class key lands only where its class has a branch: `tiling` is `at` every user, `homeDarwin` lands on mac users only (template platforms/darwin.nix:40-43; README:359). No `isDarwin`.
- substitute = `excludes` + `includes`; excludes wins in the subtree (template hosts/web-2.nix; README:369,556).
- channel `to = e: <pred>` routes emissions to other scopes: user to host `to = e: e.host` (README:396-401), fleet-wide `to = _: ren.fleet.main` (README:405).
- channel `type` checks every emission and names scope, aspect, channel (README:251; template features/monitoring.nix:18-23).
- channel `into` returns a class key: one consumer writes the class content (README:253,403; flake-inputs to flake-file).
- pools are content args: a consumer aspect reads the folded pool (README:42-45 example `persist`).
- fold `one` = exactly one emitter, else error (README:305; deploy.nix:12-31).
- `is P x` in content, `nearest K s`, `upTo` replace "where am I" reads (README:290-292).

## PREDICATES (lib read: ren/lib/predicates.nix, activation.nix, nearest.nix, pipeline-args.nix)
How they compile (activation.nix:34-49): `at` becomes a DNF over (aspect, scope) atoms.
- aspect ref = atom "a@s" (:36-37). kind ref = subkind match, follows `is` (predicates.nix:20-21). instance ref = id_hash identity (:22-23).
- `within P` = P at ANY proper ancestor (:44-45). `has P` = P at ANY child (:46-47). `not` flips (:49), so a cycle through it is "not stratified".
- include: a is active at s if an includer is active at s OR at any ancestor of s (:63). excludes: no excluder active at s or an ancestor (:62); excludes win.
- `when f` sees bindings only (:38-39). That is a data test, not composition: use it only on real data values.
- `nearest K s`: instance of the nearest ancestor-or-self matching K, else null (nearest.nix:4-10); used in channel `to` (template tests/nearest.nix:33).
- `upTo K e = and [ K (anyOf [ e (has e) ]) ]` (nearest.nix:11-22): e itself if a K, else the K that e is a child of. A user in a guest reaches the guest, never the host.
- `is P x` is a CONTENT ARG (pipeline-args.nix:24): for one value inside a module (template features/sync.nix:41 `tray.enable = is ren.aspects.desktop parent`), never for gating.
- bindings: each instance on the path binds under its kind name AND every superkind; nearest wins (README:204). So `machine` in content = nearest host/mac/guest.
Rules for vix: gate by aspect refs + kind/instance refs + within/has/upTo; `when` only for real data; `is` only inside a value.

Predicate findings (add to plan):
- P1 hand-rolled nearest: helpers.nix:5 `place` walks `s.parent`. It is used at accounts.nix:12, dots.nix:44, home-manager.nix:22. v2: an abstract kind `place` (fields system, channel, checkout); `machine.is = place`, `home.is = place` (subkind chains: scopes.nix:29). Content asks for `{ place, ... }`, the nearest binding. Delete `place` and the duplicated checkout fields (dots.nix:21-22).
- P2 helpers.nix:4,10 re-implement `opt`/`maybe`, which Ren ships as `ren.lib.opt`/`ren.lib.maybe` (README:315). Drop them and point `vix.opt` users at `ren.lib`.
- P3 frodo-guests.nix:33-36 `and [ guest (when (s: same s.on ren.host.frodo)) ]` becomes `and [ ren.kinds.guest (within ren.host.frodo) ]` (guests spawn below their host, microvm.nix:15-16).
- P4 guest leak: SOLVED in vix already. frodo-guests.nix:38 `excludes = ren.aspects.frodo.includes` drops the host includes at every guest of frodo. So facts moved into `frodo.includes` are excluded at guests for free. Design item 1 OPEN closes; every host with guests copies this line.
- P5 `firewall` channel: `to = e: ren.lib.upTo ren.kinds.host e` (not `e.host`): correct for users inside guests. `login-shells` already uses `to = e: has e` (accounts.nix:25).
- P6 user data gates: `admin` is a bool field read by `when` 3 times (accounts.nix:54,67). v2: user activator `ren.aspects.vic = { at = ren.user.vic; includes = [ ren.aspects.admin ]; }`; `admin` becomes a marker; `admin-wheel.at = and [ ren.aspects.admin (within ren.kinds.host) ]`; `primary-user.at = and [ ren.kinds.mac (has ren.aspects.admin) ]`. `shell` stays data (a value, not a gate).
- P7 env langs: `when (elem "rust" s.env.langs)` in envs/{rust,python,go,node}.nix is the vim pattern again (string list, env.nix:16). v2: env activators `ren.aspects.rustenv = { at = ren.env.rustenv; includes = [ ren.aspects.env-rust ]; }`; drop `langs`.
- P8 roles.nix `inRole` (:11-22) re-implements "nearest machine has role" with within/not-within-guest. After facts become includes and guests exclude them (P4), plain aspect refs work: `vic-gui.at = and [ vic-headless graphical ]`.

## MEASURED
- `when (` sites outside docs: 77 in vix (rg). sini features/ + roles/: 0 `when (s`. sini composes by role includes (roles/workstation.nix:3-4).
- Hot spots: vic/nvf 40, roles*.nix 5, community/power.nix 2, nix-settings.nix 2, features/accounts.nix 3.

## DESIGN v2 (ranked; each replaces checks)

1. Host facts become include-only aspects (kills `form cpu gpu wifi keyboard firmware desktops workstation` fields)
   - now: typed enum fields (topology/machine.nix:13-40) + `when (s: s.host.form == "laptop")` in community/*.nix, roles.nix:29,38.
   - v2: fields go. Community aspects lose `at`. Host activators include them; derived features use the aspect ref.
     ```nix
     ren.aspects.frodo = { at = ren.host.frodo; includes = with ren.aspects; [ trusted laptop macos-keys niri-desktop ]; };
     ren.aspects.nargun = { at = ren.host.nargun; includes = with ren.aspects; [ workstation kvm-amd macos-keys xfce-desktop kde-desktop niri-desktop enthium ]; };
     ren.aspects.laptop-thermald = { at = ren.lib.and [ ren.aspects.laptop ren.aspects.kvm-intel ]; nixos.services.thermald.enable = true; };
     ren.aspects.graphical.at = ren.lib.anyOf [ ren.aspects.niri-desktop ren.aspects.kde-desktop ren.aspects.xfce-desktop ren.aspects.wsl ren.aspects.mac-workstation ];
     ```
   - power.nix local `laptop` predicate (power.nix:4-7) disappears; laptop + power = one feature file community/laptop.nix.
   - guest leak: includes reach the subtree (activation.nix:63). vix already handles this: frodo-guests.nix:38 `excludes = ren.aspects.frodo.includes`. Facts moved into frodo.includes are excluded at guests with no new code (P4). Oracle: the frodo drvPath is unchanged (guests live inside it).

2. Tiers and roles as aspects, not `within` gymnastics
   - now: people/vic.nix:7-21 tiers + roles.nix `inRole` helper with `within`/`not within guest`.
   - v2: with facts as host includes, user scopes under the host already see them (subtree). `vic-gui.at = and [ vic-headless graphical ]`, `vic-desktop.at = and [ vic-full vic-gui ]` (repeats in terminals.nix:9-11, browsers.nix:12-14, editors.nix:10-11). `inRole` goes once guests exclude host facts (item 1 OPEN).

3. vim profiles = activators; feature strings go
   - now: 40-string enum (editors/vim.nix:10-23) + 40 `when (elem "x" s.vim.features)` in vic/nvf.
   - v2: feature aspects drop `at`; one activator per profile (template hosts/lb.nix shape). Shared sets = bundle aspects (`vim-snacks-all` includes snacks, -keys, -header).
     ```nix
     ren.aspects.vim-nvim = { at = ren.vim.nvim; includes = with ren.aspects; [ vim-snacks-all vim-blink vim-lsp vim-jj vim-rust vim-moonbit ]; };
     ```
   - `vim-theme` `when (theme != null)` stays: it reads data, not a feature.

4. Platform split by class key, then a typed channel for user services
   - now: `lib.mkIf isLinux` / `isDarwin` in headroom.nix:62/78, atuin.nix:32/52, ai/vic/tools.nix:66/81, claude.nix:35, lightjj.nix:31.
   - step 1: move to `homeLinux` / `homeDarwin` keys (darwin.nix:40-43 precedent).
   - step 2: channel `user-services` (`fold.attrs`, `type` = submodule `{ exec; args; interval ? null; env ? {}; }`, `at = user`, `to = e: e`). Features emit data once. Two consumer aspects read the pool: `services-systemd` (`homeLinux`: services + timers) and `services-launchd` (`homeDarwin`: agents). headroom/atuin/omni-ingest/lightjj write one record each, no platform code.

5. Channels for every "many features emit, one writes" spot
   - `mcp-servers` (`fold.attrs`, typed): emitters mcp.nix, tools.nix:80, headroom.nix:46, ai/vic/tools.nix:91. Consumer ai-claude writes `programs.claude-code.mcpServers` and derives `mcp__<srv>` allow rules into its own config (no hand list like mcp.nix:10). Precedent sini channels/agents-am.nix:4-8 + features/dev/ai/serena.nix:4-9.
   - `fish-functions`: emacs.nix:77 writes `programs.fish.functions` directly; emit instead.
   - `fish-conf` (`fold.attrs`, name to text): editors.nix:76, fish.nix:16-19 write `.config/fish/conf.d/*`.
   - `firewall` (`fold.set` of ports, `at = anyOf [ host (and [ user (within host) ]) ]`, `to = e: ren.lib.upTo ren.kinds.host e` (P5)): rdesk ports (community/rdesk.nix:8-19) from a user feature reach the host (impermanence precedent README:396-401).
   - `editor` (`fold.one`): one `EDITOR` per user (nvim.nix sets it); a second emitter is an error, not a silent override.

6. One aspect name per feature (multi-file merge, README:270)
   - jujutsu x4 (vcs/jujutsu/*.nix) -> `jujutsu`; rdesk `vic-rdesk` + `vix-rdesk` -> `rdesk`, one file (anydesk unfree next to anydesk); `vic-nvim` + `vic-nvim-gui` -> `nvim` with `homeManager` + a `vic-gui`-gated bundle.
   - risk: two files of one aspect must not emit one channel with different values (README:270). Only jujutsu.nix:13 emits.

7. Group stacks as activator aspects
   - 18 vic/ai aspects all `at = vic-headless`. v2: members drop `at`; `ren.aspects.ai = { at = ren.aspects.vic-full; includes = [ ... ]; }`. Same for `vcs`, `shell`, `dev`. One switch per stack; iso drops ai via vic-full. Decision for vic: ai on iso and guests? (guests run claude: frodo-guests.nix:1, so ai must reach guests).

8. Directories by feature (paths are for humans, README:105)
   - `vic/editor/{nvim/,emacs.nix,vscode.nix}` (from nvf/, edit/), `vic/desktop/{browsers,terminals,fonts,desktop-tools,rdesk}.nix`, `vic/secrets/{secrets,ssh}.nix`, `vic/ai/{harness,mcp,skills,hooks,agents}` (drop the ai/ vs ai/vic/ origin split), `roles/{roles,facts,wsl,installer}.nix`, `channels/` only for channels with no single owner feature.
   - risk: relative imports (`./_fish`, `./skills`, `./memory`), dots path `modules/vic/dots/` (vic/dots.nix:14), docs/_readme-dirs.nix.

## IMPLEMENTATION PLAN (vic: "do all 8", 2026-10-21)

Rules for every rung: sonnet/med, one jj workspace per lane (the supervisor makes and lands it, the agent never runs jj), ≤5 min. A rung edits ONLY the files listed for it. No eval or build without vic's OK (memory no-build-without-approval).
- PARSE oracle (free, every rung): `for f in <touched>; do nix-instantiate --parse "$f" >/dev/null || echo "FAIL $f"; done` gives no output, and `nixfmt --check <touched>` exits 0.
- EVAL oracle (vic-gated, run by a haiku probe at lane end): run every command capped (vic/ai/vic/rules/nix-eval.md): `timeout 300 systemd-run --user --scope -q -p MemoryMax=12G nix eval --raw .#<attr>.drvPath`. Compare with the R0 baseline. Every rung here is a refactor, so the expected result is identical drvPaths. Any diff is a finding: report the attr, do not "fix" the oracle.
- Exit 124/137 under the cap = finding, never re-run uncapped.

R0 (haiku probe, vic-gated, before any lane): record baseline drvPaths in `vic/ai/vic/pm/notes/ren-org-baseline.txt`. Cover all `nixosConfigurations` (frodo nargun bombadil smaug mordor nienna annatar + rest), `darwinConfigurations.varda`, all `homeConfigurations`, `packages.x86_64-linux.{nvim,neovim}` and their `-gui`. Enumerate the names with `nix eval .#nixosConfigurations --apply builtins.attrNames` (same cap).

F: channel declarations (runs first; others emit into these). Owns: `modules/features/`.
- F1: new `features/user-services.nix`: channel `user-services` (fold attrs; type submodule `{ exec : str; args : listOf str = []; interval : nullOr str = null; env : attrsOf str = {}; }`; at user; `to = e: e`), consumers `services-systemd` (`homeLinux`) and `services-launchd` (`homeDarwin`), both `at = ren.kinds.user`. New `features/firewall.nix`: channel `firewall` (fold set of ports; `at = anyOf [ host (and [ user (within host) ]) ]`; `to = e: ren.lib.upTo ren.kinds.host e` (P5)) and consumer `firewall` at host writing `networking.firewall.allowed{TCP,UDP}Ports`. An empty pool means no `into`, so there is no drv change on hosts without emitters.

A: host facts + tiers (items 1, 2, 6-rdesk). Owns: `community/ hosts/ homes/ topology/ roles*.nix people/ platforms/microvm.nix vic/rdesk.nix`.
- A1 community/: drop `at` from the fact aspects laptop kvm-amd kvm-intel nvidia wl-broadcom macos-keys all-firmware enthium {niri,kde,xfce,gnome}-desktop. Add include-only `workstation`, `mac-workstation` (+ `wsl`, `iso` in roles). Merge power.nix into laptop.nix: `laptop-power.at = ren.aspects.laptop`, `laptop-thermald.at = and [ laptop kvm-intel ]`. `bootable.at = workstation`, `nix-settings.at = anyOf [ workstation wsl mac-workstation ]`. Remove the `when (s: s.host.*)` checks in community/.
- A2 hosts/ frodo nargun bombadil smaug: move the fact fields into the activator `includes` (create `ren.aspects.<host> = { at = ren.host.<host>; includes = [...]; }` where missing).
- A3 hosts/ mordor nienna annatar varda + homes/: the same as A2.
- A4 topology/machine.nix: delete the fields form cpu gpu wifi keyboard firmware desktops workstation layouts. roles.nix: `graphical.at = anyOf [ niri-desktop kde-desktop xfce-desktop gnome-desktop wsl mac-workstation ]`, `installer.at = iso`. roles-wsl.nix and roles-installer.nix lose `when`. Guest leak: keep frodo-guests.nix:38 `excludes = ren.aspects.frodo.includes` (P4); its `at` becomes `and [ guest (within ren.host.frodo) ]` (P3). No guest-base.
- A4b (P1, P2) topology/ + helpers.nix + platforms/{nixos,darwin,home-manager}.nix + features/accounts.nix + vic/dots.nix: abstract kind `place` (system, channel, checkout), `machine.is = place`, `home.is = place`. Uses of `vix.place` become a `{ place, ... }` arg. Drop helpers `place`, `opt`, `maybe` and use `ren.lib.opt`/`ren.lib.maybe`. This is a cross-dir rung: run it alone, after A4 and before V/AI/S (they read `vix.opt`). Then grep: `rg -n 'vix\.(place|opt|maybe)' modules` = 0.
- A4c (P6) features/accounts.nix + people/vic.nix: `admin` becomes a marker aspect included by the `vic` user activator; admin-wheel and primary-user use aspect refs; the `admin` field goes.
- E1 (P7) envs/: env activators include env-<lang>; drop the `langs` field. Owns envs/ + the env instances' files.
- A5 people/vic.nix + roles.nix: `vic-gui.at = and [ vic-headless graphical ]`, `vic-secrets.at = and [ vic-headless trusted ]`, new `vic-desktop.at = and [ vic-full vic-gui ]`; delete `inRole`, `on-graphical`, `on-trusted`. Then use `vic-desktop` in vic/shell/terminals.nix, vic/edit/browsers.nix and vic/edit/editors.nix. That is a cross-lane touch: do it in lane S rung S4 after A lands.
- A6 rdesk: merge vic/rdesk.nix and community/rdesk.nix into one `rdesk` aspect in vic/rdesk.nix. Ports become a `firewall` emission. It stays disabled (no `at`).
- Lane eval oracle: the R0 drvPaths are identical, which proves that guests did not inherit the host facts (frodo's toplevel contains its guests). Also check that `rg -n 'when \(s: s\.(host|mac)\.' modules` gives 0 hits.

V: vim (item 3). Owns: `editors/vim.nix vic/nvf/`.
- V1 vic/nvf/{ui,langs,editing}.nix: drop the `at = ren.lib.when (... features ...)` lines.
- V2 vic/nvf/{snacks,ai,plugins,mini,vcs,moonbit}.nix: the same. Add bundle `vim-snacks-all` (includes snacks, -header, -keys, -extras as the profiles use them).
- V3 editors/vim.nix: delete the `features` list + field. vic/nvf/profiles.nix: one activator per profile `ren.aspects.vim-<p> = { at = ren.vim.<p>; includes = [...]; }` with the exact current feature list mapped to refs.
- Oracle: `rg -c 'vim.features' modules` = 0. Eval: the `packages.*.{nvim,neovim}*` drvPaths are identical.

AI: vic/ai (items 4, 5-mcp, 7-ai, 6). Owns: `vic/ai/` (except pm/notes).
- AI1: `isLinux` + `mkIf` in headroom.nix:62/78, claude.nix:35, lightjj.nix:31 become `homeLinux`/`homeDarwin` keys.
- AI2: the headroom, omni-ingest (vic/tools.nix:66,81) and lightjj services become `user-services` emissions (needs F1).
- AI3: new channel `mcp-servers` in claude.nix (fold attrs, at user, `to = e: e`). ai-claude writes `programs.claude-code.mcpServers` from the pool. Emitters: mcp.nix, tools.nix:80, headroom.nix:46, vic/tools.nix:91.
- AI4: stack activator `ren.aspects.ai = { at = ren.aspects.vic-headless; includes = [ all ai-* ]; }`; members drop `at`. vic-headless keeps guests and iso the same as today; vic decides on narrowing later.
- Eval: home drvPaths identical (mcp JSON keys sorted, so identical).

S: shell/edit/vcs/dev (items 4-atuin, 5-fish, 5-editor, 6, 7). Owns: `vic/shell/ vic/edit/ vic/vcs/ vic/dev/`.
- S1: atuin.nix:32,52 becomes a `user-services` emission (needs F1). emacs.nix:77 becomes a `fish-functions` emission.
- S2: new channel `fish-conf` (fold attrs, name to text) in fish.nix. Emitters: fish.nix:16-19, editors.nix:76. New channel `editor` (fold one) in nvim.nix; fish or the hm consumer sets `home.sessionVariables.EDITOR`.
- S3: jujutsu x4 become one `jujutsu` aspect across 4 files (only jujutsu.nix emits `dots`). `vic-nvim` + `vic-nvim-gui` become `nvim` + bundle.
- S4 (after A5): `vic-desktop` in terminals/browsers/editors. Stack activators `vcs`, `shell`, `dev`; members drop `at`.

M: directory moves (item 8). Last, alone, one rung, no content edits: `jj mv`-free plain `mv` by the supervisor's agent, then fix relative paths (`./_fish`, `./skills`, `./memory`, dots base vic/dots.nix:14) and docs/_readme-dirs.nix. Oracle: parse plus R0 drvPaths identical (paths are for humans, README:105).

Order and parallelism: R0, then F, then A1-A4, then A4b alone, then A4c/A5/A6 ∥ E1 ∥ V ∥ AI ∥ S (disjoint directories; S4 waits for A5), then M. F1 firewall uses `to = e: ren.lib.upTo ren.kinds.host e` (P5). Each lane lands on main after its eval oracle (memory jj-own-main).

## SKIP
- `vim-theme` `when theme != null`, envs/*.nix `when` on env data, accounts.nix `when` on user fields: they read data, no aspect fits.
- battery/AC kind, server form, user role kind: no consumer today.
- sini `-am/-nz` channel file naming: vix keeps a channel beside its owner feature.
- not read: docs/ generators, envs/ internals, hosts/ except frodo, nargun, frodo-guests.
