{ config, lib, pkgs, USER, DOTS, ... }: {
  home-manager.users.${USER} = {

    programs.git = {
      enable = true;
      userName = "Victor Hugo Borja";
      userEmail = "vborja@apache.org";

      extraConfig = { init = { defaultBranch = "main"; }; };

#       aliases = {
#         "fap" = "fetch --all -p";
#       };

      ignores = [ ".DS_Store" "*.swp" ];

      includes = [ ]; # { path = "${DOTS}/git/something"; }

      lfs.enable = true;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
      };
    };

  };

}
