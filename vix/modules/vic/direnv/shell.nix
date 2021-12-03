{ config, pkgs, lib, vix, USER, HOME, direnv_dir, ... }:
lib.mkMerge [
  {
    home-manager.users.${USER}.home.file = {
      ".config/direnv/lib/use_vix_env.sh".text = ''
        function use_vix-env() {
          source ~/"${direnv_dir}/$1-env.sh"
        }
      '';
    };
  }
  #,
  {
    home-manager.users.${USER}.home.file = lib.mkMerge (lib.mapAttrsToList
      (name: shell: {
        "${direnv_dir}/${name}-env.sh".source =
          "${vix.lib.shellDirenv name shell}/env";
      }) pkgs.pkgShells);
  }
]
