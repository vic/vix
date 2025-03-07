{ pkgs, ... }:
{

  home.packages = [ pkgs.difftastic ];

  programs.git = {
    enable = true;
    userName = "Victor Borja";
    userEmail = "vborja@apache.org";
    signing.format = "ssh";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      pager.difftool = true;
      diff.tool = "difftastic";
      difftool.prompt = false;
      difftool.difftastic.cmd = "${pkgs.difftastic}/bin/difft $LOCAL $REMOTE";

      github.user = "vic";
      gitlab.user = "vic";

      core.editor = "vim";
      url."git@github.com:".insteadOf = "https://github.com/";
    };
    aliases = {
      "dff" = "difftool";
      "fap" = "fetch --all -p";
      "rm-merged" =
        "for-each-ref --format '%(refname:short)' refs/heads | grep -v master | xargs git branch -D";
      "recents" =
        "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
    };
    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv"
      ".envrc"
      ".envrc.local"
      ".env"
      ".env.local"
      "/devshell.toml"
      "/.tool-versions"
      "*.key"
      "/vic"
      "*~"
    ];
    includes = [ ];
    # { path = "${DOTS}/git/something"; }

    lfs.enable = true;

    delta.enable = true;
    delta.options = {
      line-numbers = true;
      side-by-side = false;
    };
  };

}
