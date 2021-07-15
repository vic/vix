{ config, pkgs, lib, vix-lib, ... }:
let
  direnv_lib = ".nix-out/direnv";
  HOME = config.home-manager.users.vic.home.homeDirectory;
in lib.mkMerge [
  {
    home-manager.users.vic.home.file = {
      ".config/direnv/lib/use_flake.sh".text = ''
        function use_flake() {
          local flake flake5
          flake="''${1:-"$PWD"}"
          flake5="$(echo "$flake" | md5)"

          cat <<EOF > ${HOME}/.direnv/$flake5-shell.nix
            (getFlake "$flake").devShell.''${currentSystem}
        EOF
          eval "$(${pkgs.lorri}/bin/lorri direnv --shell-file ${HOME}/.direnv/$flake5-shell.nix)"
        }
      '';

      ".config/direnv/lib/use_vix.sh".text = ''
        function use_vix() {
          source ~/"${direnv_lib}/$1.sh"
        }
      '';

      ".config/direnv/lib/use_vix_env.sh".text = ''
        function use_vix-env() {
          source ~/"${direnv_lib}/$1-env.sh"
        }
      '';

    };
  }
  #,
  {

    home-manager.users.vic.home.file = lib.mkMerge (map (shellName: {
      "${direnv_lib}/${shellName}.sh".text = ''
        eval "$(${pkgs.lorri}/bin/lorri direnv --shell-file ${HOME}/${direnv_lib}/${shellName}.nix)"'';

      "${direnv_lib}/${shellName}.nix".text = ''
        (builtins.getFlake "${HOME}/.nix-out/vix").packages.''${builtins.currentSystem}.pkgShells.${shellName}'';

    }) (lib.attrNames config.pkgSets));

  }
  #,
  {
    home-manager.users.vic.home.file = lib.mkMerge (lib.mapAttrsToList
      (name: shell: {
        "${direnv_lib}/${name}-env.sh".source =
          "${vix-lib.shellDirenv name shell}/env";
      }) pkgs.pkgShells);
  }
]
