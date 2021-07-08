{ config, pkgs, vix-lib, lib, ... }: {

  services.lorri.enable = true;
  home-manager.users.vic = {
    home.packages = config.pkgSets.vic;

    home.file = {
      "link-vix" = {
        target = ".nix-link/vix";
        source = builtins.toPath ./..;
      };

      "link-openjdk" = {
        target = ".nix-link/openjdk";
        source = builtins.toPath pkgs.openjdk;
      };

       "direnv_use_shell" = {
         target = ".config/direnv/lib/use_shell.sh";
         text = ''
         function use_shell () {
           watch_file $HOME/.config/direnv/envs/$1.bash
           source $HOME/.config/direnv/envs/$1.bash
         }
         '';
       };
    } // (
      lib.mapAttrs' (name: shell:
        let drv = vix-lib.shellDirenv name shell;
        in lib.nameValuePair "direnv_use_${name}" {
          target = ".config/direnv/envs/${name}.bash";
          source = "${drv}/env";
        }
      ) pkgs.pkgShells
    );

  };

}
