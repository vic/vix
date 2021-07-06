{ config, pkgs, vix-lib, lib, ... }: {

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
