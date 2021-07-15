{config, lib, pkgs, USER, DOTS, ...}: 
{
home-manager.users.${USER} = {

    programs.git = {
      enable = true;
      userName = "Victor Borja";
      userEmail = "vborja@apache.org";

      extraConfig = {
        init = { defaultBranch = "main"; };
      };

      aliases = {
        "fap" = "fetch --all -p";
        "rbh" = "rebase remotes/origin/HEAD";
        "rih" = "rebase -i remotes/origin/HEAD";
        "fph" = "push --force-with-lease origin HEAD";
	"fix" = "commit --all --fixup amend:HEAD";
	"caa" = "commit --amend --all --reuse-message HEAD";
	"cam" = "commit --amend --all --message";
      };

      ignores = [ ".DS_Store" "*.swp" ];

      includes = []; # { path = "${DOTS}/git/something"; }

      lfs.enable = true;
      delta.enable = true;
      delta.options = {
       line-numbers = true;
       side-by-side = true;
      };
    };

  };

}