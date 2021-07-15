{ config, pkgs, lib, ... }:
let direnv_lib = ".nix-out/direnv";
in lib.mkMerge [
  {
    home-manager.users.vic.home.file = {
      ".config/direnv/lib/use_flake.sh".text = ''
        function use_flake() {
          local flake flake5
          flake="''${1:-"$PWD"}"
          flake5="$(echo "$flake" | md5)"

          cat <<EOF > ~/.direnv/$flake5-shell.nix
            (getFlake "$flake").devShell.''${currentSystem}
        EOF
          eval "$(${pkgs.lorri}/bin/lorri direnv --shell-file ~/.direnv/$flake5-shell.nix)"
        }
      '';

      ".config/direnv/lib/use_vix.sh".text = ''
        function use_vix() {
          source ~/"${direnv_lib}/$1.sh"
        }
      '';

    };
  }
  # ----------
  {

    home-manager.users.vic.home.file = lib.mkMerge (map (shellName: {
      "${direnv_lib}/${shellName}.sh".text = ''
        eval "$(${pkgs.lorri}/bin/lorri direnv --shell-file ~/${direnv_lib}/${shellName}.nix)"'';

      "${direnv_lib}/${shellName}.nix".text = ''
        (builtins.getFlake "''${builtins.getEnv "HOME"}/.nix-out/vix").packages.''${builtins.currentSystem}.pkgShells.${shellName}'';

    }) (lib.attrNames config.pkgSets));

  }
]
