# atuin: fish history search, local only. Daily sops-encrypted snapshot lands in vic/secrets.
# Restore (run by vic): vic-sops-get atuin-history.db > ~/.local/share/atuin/history.db
{ ren, ... }:
let
  sopsConfig = "/home/vic/hk/vix/modules/vic/sops.yaml";
  out = "/home/vic/hk/vix/modules/vic/secrets/atuin-history.db";
in
{
  ren.aspects.atuin = {
    at = ren.aspects.vic-headless;
    homeManager =
      { pkgs, lib, ... }:
      {
        programs.atuin = {
          enable = true;
          enableFishIntegration = true;
          settings = {
            auto_sync = false;
            update_check = false;
            filter_mode_shell_up_key_binding = "directory";
            secrets_filter = true;
            history_filter = [
              "^.*(password|passwd|token|secret|api[_-]?key).*=.*"
              "^export .*(KEY|TOKEN|SECRET|PASSWORD)"
              "^.*(Authorization|Bearer) "
              "^age-keygen"
              "^sops "
            ];
          };
        };

        systemd.user.services.atuin-backup = lib.mkIf pkgs.stdenv.isLinux {
          Unit.Description = "Encrypt atuin history into the vix repo";
          Service = {
            Type = "oneshot";
            Nice = 19;
            ExecStart = pkgs.writeShellScript "atuin-backup" ''
              set -eu
              export PATH=${lib.makeBinPath [ pkgs.sops pkgs.sqlite pkgs.coreutils ]}
              src="$HOME/.local/share/atuin/history.db"
              [ -f "$src" ] || exit 0
              tmp=$(mktemp)
              trap 'rm -f "$tmp"' EXIT
              sqlite3 "$src" ".backup '$tmp'"
              sops --encrypt --config ${sopsConfig} --input-type binary --output-type binary "$tmp" > ${out}.new
              mv ${out}.new ${out}
            '';
          };
        };

        systemd.user.timers.atuin-backup = lib.mkIf pkgs.stdenv.isLinux {
          Unit.Description = "Daily atuin history backup";
          Timer = {
            OnCalendar = "daily";
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      };
  };
}
