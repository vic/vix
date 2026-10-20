# git: identity from the user binding, ssh signing, difftastic, delta pager.
{ ren, ... }:
{
  # any feature emits the paths it wants git to ignore; git writes them once.
  ren.channels.git-ignores = {
    fold = ren.lib.fold.list;
    at = ren.kinds.user;
    to = e: e;
  };
  ren.aspects.git = {
    dots.".config/gh/config.yml" = "config/gh/config.yml";
    at = ren.aspects.vic-headless;
    git-ignores = { ... }: [
      ".DS_Store"
      "*.swp"
      ".direnv"
      ".envrc"
      ".envrc.local"
      ".env"
      ".env.local"
      ".jj"
      "devshell.toml"
      ".tool-versions"
      "/.github/chatmodes"
      "/.github/instructions"
      "/vic"
      "*.key"
      "target"
      "result"
      "out"
      "old"
      "*~"
      ".aider*"
      ".crush*"
      "CRUSH.md"
      "GEMINI.md"
      "CLAUDE.md"
      ".workspaces"
      ".agents"
      ".claude"
      "AGENT*"
      "docs/superpowers"
    ];
    homeManager =
      {
        lib,
        pkgs,
        user,
        git-ignores,
        ...
      }:
      {
        home.packages = [ pkgs.difftastic ];
        programs.git = {
          enable = true;
          signing.format = "ssh";
          settings = {
            user.name = user.fullName;
            user.email = user.email;
            init.defaultBranch = "main";
            pull.rebase = true;
            pager.difftool = true;
            diff.tool = "difftastic";
            difftool.prompt = false;
            difftool.difftastic.cmd = "${pkgs.difftastic}/bin/difft $LOCAL $REMOTE";
            github.user = "vic";
            gitlab.user = "vic";
            core.editor = "vim";
            alias = {
              "dff" = "difftool";
              "fap" = "fetch --all -p";
              "rm-merged" =
                "for-each-ref --format '%(refname:short)' refs/heads | grep -v master | xargs git branch -D";
              "recents" =
                "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
            };
          };
          ignores = lib.unique (builtins.concatLists git-ignores);
          includes = [ ];
          lfs.enable = true;
        };

        programs.delta.enable = true;
        programs.delta.options = {
          line-numbers = true;
          side-by-side = false;
        };
      };
  };
}
