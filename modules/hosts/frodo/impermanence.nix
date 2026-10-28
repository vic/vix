# frodo impermanence: system state persisted in /nix/persist, btrfs root rolled back each cold boot (design: vic/pm/notes/impermanence-design.md). /home is never wiped.
{
  sven,
  lib,
  inputs,
  ...
}:
let
  # disko partition `root` of disk `main`; NVMe names swap between boots, so never /dev/nvmeX.
  dev = "/dev/disk/by-partlabel/disk-main-root";
  devUnit = "dev-disk-by\\x2dpartlabel-disk\\x2dmain\\x2droot.device";
  inherit (sven.lib) all within;
in
{
  sven.aspects.frodo-impermanence = {
    at = sven.host.frodo;
    flake-file.inputs.impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    persist.files = [
      "/etc/machine-id"
      "/etc/adjtime"
      "/var/lib/systemd/credential.secret"
    ];
    persist.directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
      "/etc/NetworkManager/system-connections"
      "/var/lib/microvms" # workspace guests (frodo-guests.nix)
      "/var/lib/machines"
      "/var/lib/fwupd"
      "/var/lib/power-profiles-daemon"
      "/var/lib/upower"
      "/var/lib/AccountsService"
      "/var/lib/lightdm"
      "/var/lib/lightdm-data"
      "/var/lib/udisks2"
      "/var/lib/private"
      "/root"
    ];
    # the same guards fail in `stage`, before any build; the NixOS assertions below stay.
    errors =
      { host, ... }:
      lib.optional (
        host.impermanence.wipeRoot && !host.impermanence.enable
      ) "frodo: impermanence.wipeRoot needs impermanence.enable"
      ++ lib.optional (
        host.impermanence.wipeRoot && !(sven.secret ? vic-password)
      ) "frodo: impermanence.wipeRoot needs sven.secret.vic-password";
    # gated on the host value (not mkIf): with both gates off this is an empty module.
    nixos =
      { host, ... }:
      let
        inherit (host.impermanence) enable wipeRoot;
      in
      {
        imports =
          lib.optional enable inputs.impermanence.nixosModules.impermanence
          ++ lib.optional wipeRoot inputs.sops-nix.nixosModules.sops;
        config = lib.optionalAttrs wipeRoot {
          assertions = [
            {
              assertion = enable;
              message = "frodo: impermanence.wipeRoot needs impermanence.enable, else all system state is deleted on boot.";
            }
            {
              assertion = sven.secret ? vic-password;
              message = "frodo: impermanence.wipeRoot rebuilds /etc/shadow each boot, so vic's password must come from nix. Declare sven.secret.vic-password first: see `## PASSWORD (vic runs first)` in modules/vic/ai/vic/pm/notes/impermanence-design.md.";
            }
          ];

          boot.initrd.systemd.enable = true;
          # sini btrfs.nix rollback-btrfs-root, without cryptroot; keeps the last root as rootfs-prev.
          boot.initrd.systemd.services.rollback-root = {
            description = "Rollback btrfs rootfs to rootfs-blank";
            wantedBy = [ "initrd.target" ];
            requires = [ devUnit ];
            after = [
              devUnit
              "systemd-hibernate-resume.service" # a resumed initrd never reaches this
            ];
            before = [ "sysroot.mount" ];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = ''
              mkdir -p /mnt
              mount -o subvolid=5 ${dev} /mnt

              if [ ! -e /mnt/rootfs-blank ]; then
                echo "no /rootfs-blank subvolume, keeping rootfs as is"
                umount /mnt
                exit 0
              fi

              if [ -e /mnt/rootfs-prev ]; then
                # nested subvolumes first (systemd containers, etc.)
                btrfs subvolume list -o /mnt/rootfs-prev |
                cut -f9 -d' ' |
                while read subvolume; do
                  echo "deleting /$subvolume subvolume..."
                  btrfs subvolume delete "/mnt/$subvolume"
                done &&
                echo "deleting /rootfs-prev subvolume..." &&
                btrfs subvolume delete /mnt/rootfs-prev
              fi

              echo "moving /rootfs to /rootfs-prev..."
              mv /mnt/rootfs /mnt/rootfs-prev

              echo "restoring blank /rootfs subvolume..."
              btrfs subvolume snapshot /mnt/rootfs-blank /mnt/rootfs

              umount /mnt
            '';
          };

          # /etc/shadow is rebuilt each boot: the password comes from sops.
          users.mutableUsers = false;
          fileSystems."/home".neededForBoot = true; # the age key is in /home, read before users are created
          sops.age.sshKeyPaths = [ ];
        };
      };
  };

  # wipeRoot rebuilds /etc/shadow each boot: the password comes from sops, read at the user scope.
  sven.aspects.frodo-wipe-root = {
    at = all [
      sven.host.frodo
      (s: s.impermanence.wipeRoot)
    ];
    secrets = lib.optional (sven.secret ? vic-password) sven.secret.vic-password;
  };

  sven.aspects.frodo-wipe-user = {
    at = all [
      sven.kinds.user
      (within sven.host.frodo)
      (_: sven.host.frodo.impermanence.wipeRoot)
    ];
    account =
      { config, ... }:
      lib.optionalAttrs (sven.secret ? vic-password) {
        hashedPasswordFile = config.sops.secrets.${sven.secret.vic-password.sopsKey}.path;
      };
    os =
      { user, ... }:
      {
        sops.age.keyFile = "/home/${user.name}/.config/sops/age/keys.txt";
      }
      // lib.optionalAttrs (sven.secret ? vic-password) {
        sops.secrets.${sven.secret.vic-password.sopsKey}.neededForUsers = true;
      };
  };
}
