{ config, pkgs, vix-lib, lib, ... }: {

  services.lorri.enable = true;
  home-manager.users.vic = {
    home.packages = config.pkgSets.vic;

    # home.file = with lib;
    #   (mapAttrs' (name: shell: 
    #     nameValuePair "direnv-${name}" 
    #     {
    #     target = ".direnv/${name}-env.bash";
    #     source = vix-lib.shellEnv name shell;
    #   }
    #   ) pkgs.pkgShells);

  };

}
