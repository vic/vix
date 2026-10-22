# frodo impermanence: design + inventory (2026-10-21)
Design only. No .nix edited, nothing switched, nothing moved. Vic activates.
Prior note: vic/notes/frodo-impermanence.md (2026-10-12). This note supersedes its device facts.

## FS (measured)
- `findmnt`: `/` = `nvme1n1p3[/rootfs]` btrfs subvolid=260 · `/home` = `[/home]` subvolid=257 · `/nix` = `[/nix]` noatime subvolid=259 · `/partition-root` = top level subvolid=5. Top level holds `hk/ home/ nix/ rootfs/`.
- `lsblk -f`: btrfs is now on **nvme1n1p3** (706G free, 22% used). The 10-12 note said nvme0n1. NVMe names swap between boots. Use only by-id / by-partlabel paths. disko.nix already uses `/dev/disk/by-id/nvme-eui.0000…2105` (fixed since 10-12).
- No LUKS. swap partition has `resumeDevice = true` (hibernate). zram swap also on.
- `/home` mount shows no `compress=zstd` although disko.nix sets it (drift, harmless, out of scope).
- `sudo -n true`: "a password is required". Sudo not used.
- System state today (`ls /var/lib`): AccountsService bluetooth dhcpcd fwupd lastlog lightdm lightdm-data logrotate.status machines **microvms** misc NetworkManager nixos portables power-profiles-daemon private systemd udisks2 upower. `/etc/ssh` has no host keys (no sshd). sops age key = `~/.config/sops/age/keys.txt` (vic/sys/secrets.nix:55), so it is in home.

## HOME INVENTORY
Design keeps `/home` persistent (see DESIGN). This table is for the optional later `wipeHome`, and for backups.
P = PERSIST · R = REGENERABLE (nix/hm/cache/tool reinstall) · ? = UNKNOWN-ASK. Sizes from `du -xsh`.

| entry | size | class | note |
|---|---|---|---|
| hk | 18G | P | all repos, jj workspaces |
| Documents | 6.3G | P | vic must-keep |
| Downloads | 1.5G | P | vic must-keep (sini puts it in /cache) |
| Pictures Desktop Music Public Templates Videos | 40M | P | xdg dirs |
| .config (all) | 1.9G | P | vic must-keep. Holds sops/age key, chromium 110M, net.imput.helium 1.2G, Code 444M, gh, jj, git, librewolf, qutebrowser |
| .claude | 4.1G | P | memory/, projects/ 1.2G, omni.db 1.6G, settings |
| .claude.json (+ .omni-bak) | 212K | P | claude account state |
| .cache/claude-ledger | 176M | P | only valuable part of .cache |
| .cache (rest) | 7.6G | R | caches |
| .ssh | 56K | P | user keys, mode 0700 |
| .local/share/keyrings | - | P | gnome keyring, mode 0700 |
| .local/share/{direnv,quipu,dnx,fish,Trash,recently-used.xbel} | - | P | direnv allow list, quipu db, fish history |
| .local/share/{nix,home-manager,applications,icons,nvim,lazyvim,nvf,…} | - | R | hm/nix managed or plugin caches |
| .local/state/{home-manager,nix,nvim,…} | - | R | |
| atuin db | - | P | not present yet (modules/vic/shell/atuin.nix is new); will be `.local/share/atuin` |
| .serena .headroom .tokenjuice .codegraph .agents .codex .copilot .cursor .dolt | ~200M | P | AI tool state, cheap to keep |
| .pki | 68K | P | nss certs |
| bin jj tmp foo santuario notes vic oeiuwq json-parser-test a lib zoom | ~160M | ? | loose user dirs |
| *.md *.py *.pl *.txt, package.json, bun.lock, pnpm-lock.yaml, node_modules (364M) | - | ? | loose files in ~; likely scratch |
| nix (388M) | 388M | ? | not ~/.nix-profile; check contents |
| .cargo .rustup .bun .npm .elm .elan go .dotnet .vscode .vscode-server .debug .compose-cache | ~3G | R | toolchains + caches |
| .nix-profile .nix-defexpr .manpath .flake (symlink to ~/hk/vix) | - | R | |
| .bash_history .gtk-bookmarks .wget-hsts | small | P | cheap |
| .Xauthority .xsession-errors* | - | R | |
| .Xdefaults .Xresources .emacs.d .icons .envrc .gitignore | small | ? | hm-managed or hand-written? |
| vms (root-owned, empty) | 0 | R | |
| .gnupg .password-store Mail .mozilla .thunderbird | absent | - | none on frodo |

## DESIGN
(a) Mechanism: **btrfs root rollback, root only.** Each boot the initrd deletes `/rootfs` and re-snapshots it from `/rootfs-blank`. `/home` and `/nix` stay as they are.
- Why: frodo is already btrfs with a separate `/rootfs` subvol. No repartition, no mkfs. Source: sini `modules/features/impermanence/btrfs.nix` (`rollback-btrfs-root`, initrd service before `sysroot.mount`), which uses the same blank-snapshot pattern. tmpfs root is rejected: it needs a new `/` fileSystem and RAM; btrfs rollback needs neither.
- Why home stays: vic's must-keep set is most of `$HOME` (hk, Documents, Downloads, all .config, .claude). Home rollback would protect almost nothing and risk everything. sini also defaults `wipeHomeOnBoot = false` (impermanence.nix settings).
- Persist store: `/nix/persist` (a plain dir on the `/nix` subvol). Stage 1 already mounts `/nix`. No new subvol, no new mount.
- Binds: nix-community/impermanence `environment.persistence."/nix/persist"` with `hideMounts = true` (sini impermanence.nix).
- System persist set (from /var/lib measured + sini static list):
  files `/etc/machine-id /etc/adjtime /var/lib/systemd/credential.secret`;
  dirs `/var/log /var/lib/nixos /var/lib/systemd /var/lib/bluetooth /var/lib/NetworkManager /etc/NetworkManager/system-connections /var/lib/microvms /var/lib/machines /var/lib/fwupd /var/lib/power-profiles-daemon /var/lib/upower /var/lib/AccountsService /var/lib/lightdm /var/lib/lightdm-data /var/lib/udisks2 /var/lib/private /root`.
  `/var/lib/microvms` matters: the workspace guests (frodo-guests.nix) live there.
- Hibernate: rollback must run only on a cold boot. Order it `after = [ "systemd-hibernate-resume.service" ]`. A resumed initrd never reaches it.

## REN SHAPE
Follow sini `modules/channels/storage-nz.nix`: a `persist` channel. Features emit their own paths; the host folds them. vix has no persist channel yet.
```nix
ren.channels.persist = {
  fold = ren.lib.fold.list;              # entries { directories; files; }
  to = e: ren.lib.upTo ren.kinds.host e; # user/feature entries reach the host
  into = { host, lib, ... }: es: {
    nixos = lib.mkIf host.impermanence.enable {
      environment.persistence."/nix/persist" = merge es // { hideMounts = true; };
    };
  };
};
# features emit next to their config, e.g. bluetooth aspect:  persist.directories = [ "/var/lib/bluetooth" ];
ren.aspects.impermanence = {
  at = ren.host.frodo;   # included by frodo
  flake-inputs = _: { impermanence.url = "github:nix-community/impermanence"; }; # no rev, lock pins
  persist.files = [ "/etc/machine-id" "/etc/adjtime" "/var/lib/systemd/credential.secret" ];
  persist.directories = [ "/var/log" "/var/lib/nixos" "/var/lib/systemd" "/root" ];
  nixos = { host, inputs, lib, ... }: {
    imports = [ inputs.impermanence.nixosModules.impermanence ]; # always: options must exist for mkIf
    boot.initrd.systemd.services.rollback-root = lib.mkIf host.impermanence.wipeRoot { /* sini btrfs.nix */ };
  };
};
ren.host.frodo.impermanence = { enable = false; wipeRoot = false; }; # both default false
```
- Two gates, both default OFF. `enable` turns on binds only (safe, nothing deleted). `wipeRoot` turns on the deletion. Building frodo with defaults changes nothing at runtime.
- `merge` = sini `helpers/mergePersist.nix` (unique union of directories/files).
- Rollback script differs from sini: no cryptroot. Mount `/dev/disk/by-partlabel/disk-main-root` with `subvolid=5`. Rename `rootfs` to `rootfs-prev` (delete the older `rootfs-prev` first) instead of deleting it. Then snapshot `rootfs-blank` to `rootfs`. One boot of undo is always kept.
- Option type: sini declares `ren.kinds.machine.impermanence` (impermanence.nix:12). vix declares the same on its host kind.

## MIGRATION (vic runs every step)
1. Back up. `sudo btrfs subvolume snapshot -r /partition-root/rootfs /partition-root/rootfs-backup-2026XXXX`. Also snapshot `/partition-root/home` read-only. Copy `~/.config/sops/age/keys.txt` off the machine.
2. Land the Ren code with both gates false. `nix build .#nixosConfigurations.frodo.config.system.build.toplevel`. Check the toplevel is equal to today's or differs only by the impermanence module import.
3. Create the blank root: `sudo btrfs subvolume create /partition-root/rootfs-blank-rw`, then `sudo btrfs subvolume snapshot -r /partition-root/rootfs-blank-rw /partition-root/rootfs-blank`. It must be empty.
4. Seed the store. `sudo mkdir -p /nix/persist`. For each persist path, `sudo cp -a --parents <path> /nix/persist/`. sini has a helper for this: `pkgs/by-name/impermanence-copy`.
5. Set `enable = true` (wipeRoot still false). `sudo nixos-rebuild boot`, reboot. Check: `findmnt | grep /nix/persist` lists every bind. Wifi, bluetooth, microvms and `journalctl -b -1` still work.
6. Dry-run the loss. List what is on root but not persisted: `sudo btrfs subvolume find-new /partition-root/rootfs 0 | awk '{print $NF}' | sort -u`, then drop paths under persisted dirs. Add any real state to `persist`. Repeat 5 until the list holds only regenerable files.
7. Optional VM check: `nixos-rebuild build-vm` checks eval and that the binds activate. It does not test the btrfs rollback (the VM disk is not this layout).
8. Set `wipeRoot = true`. `sudo nixos-rebuild boot`, reboot. Check `/partition-root/rootfs-prev` exists and the system works.
9. Rollback at any step: pick the previous generation in systemd-boot. If root is broken: boot an older generation, `mv /partition-root/rootfs /partition-root/rootfs-bad`, `btrfs subvolume snapshot /partition-root/rootfs-prev /partition-root/rootfs` (or `rootfs-backup-*`).

## PASSWORD (vic runs first)
Do this before step 8. With `wipeRoot = true`, `/etc/shadow` is rebuilt each boot and `users.mutableUsers = false`. The build fails with an assertion until `ren.secret.vic-password` exists.
Code: modules/hosts/frodo-impermanence.nix. The sops age key stays at `~/.config/sops/age/keys.txt`, so wipeRoot also sets `fileSystems."/home".neededForBoot = true`.
1. Make the hash. Type your login password at the prompt: `mkpasswd -m yescrypt > /tmp/vic-pw.hash` (`nix shell nixpkgs#mkpasswd` if missing). The file holds one line.
2. Encrypt it from the vix checkout: `cd ~/hk/vix && sops --config modules/vic/sops.yaml encrypt --input-type binary --output-type binary /tmp/vic-pw.hash > modules/vic/secrets/vic-password`.
3. Delete the plain hash: `shred -u /tmp/vic-pw.hash`.
4. Add this line to modules/security/secret.nix, next to the other `bin` secrets:
   `ren.secret.vic-password = bin ../vic/secrets/vic-password // { sopsKey = "vic-password"; };`
5. Check: `nix eval .#nixosConfigurations.frodo.config.users.users.vic.hashedPasswordFile` (with wipeRoot on) prints `"/run/secrets-for-users/vic-password"`.

## RISKS
- Missed system state is deleted on the next boot after step 8. Mitigation: step 6 diff, plus `rootfs-prev` keeps one boot of undo.
- Hibernate: rollback before resume corrupts the resume image. Mitigation: order after `systemd-hibernate-resume.service`. Test one hibernate cycle after step 8.
- NVMe names swap (measured: nvme0 then nvme1). Any `/dev/nvmeX` path in the script will break. Use by-partlabel only.
- `/var/lib/microvms` guests: if not persisted, all guest disks go. It is in the static list.
- users/passwords: `/etc/shadow` is rebuilt each boot. vic's password must be declared (`hashedPasswordFile` or `mutableUsers = false`). Otherwise login fails after the first wipe. CHECK before step 8.
- disko format of this file still wipes the disk. Never run `disko --mode format/destroy` on frodo.

## OPEN (vic decides)
1. Root-only wipe (recommended) vs also wipe home later with the inventory above.
2. Store at `/nix/persist` (recommended, no new subvol) vs a new `/persist` subvol (sini layout, needs one `btrfs subvolume create` + `neededForBoot` mount).
3. One store, or split `persist` + `cache` like sini (cache excluded from backups).
4. The `?` rows: loose dirs and files in `~` (bin, jj, tmp, foo, santuario, notes, nix, *.md, node_modules). Keep, move into ~/hk or ~/Documents, or delete.
5. Is vic's login password declared in nix today? (gates step 8)
6. Workspaces in /tmp: decided separately (not in this design).
