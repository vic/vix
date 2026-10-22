# git: identity from the user binding, ssh signing, difftastic, delta pager.
{ ren, inputs, ... }:
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
      "*.age"
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
      let
        delta = lib.getExe pkgs.delta;
        lfs = lib.getExe pkgs.git-lfs;
        git = inputs.nix-wrapper-modules.wrappers.git.wrap {
          inherit pkgs;
          settings = {
            user.name = user.fullName;
            user.email = user.email;
            init.defaultBranch = "main";
            pull.rebase = true;
            pager.difftool = true;
            pager.blame = delta;
            diff.tool = "difftastic";
            difftool.prompt = false;
            difftool.difftastic.cmd = "${pkgs.difftastic}/bin/difft $LOCAL $REMOTE";
            github.user = "vic";
            gitlab.user = "vic";
            core.editor = "vim";
            core.pager = delta;
            core.excludesFile = pkgs.writeText "git-ignore" (
              lib.concatStringsSep "\n" (lib.unique (builtins.concatLists git-ignores)) + "\n"
            );
            core.attributesFile = pkgs.writeText "git-attributes" "* merge=mergiraf\n";
            interactive.diffFilter = "${delta} --color-only";
            delta = {
              line-numbers = true;
              side-by-side = false;
            };
            merge.conflictStyle = "diff3";
            merge.mergiraf = {
              name = "mergiraf";
              driver = "${lib.getExe pkgs.mergiraf} merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
            };
            filter.lfs = {
              clean = "${lfs} clean -- %f";
              process = "${lfs} filter-process";
              required = true;
              smudge = "${lfs} smudge -- %f";
            };
            gpg.format = "ssh";
            gpg.ssh.program = "${pkgs.openssh}/bin/ssh-keygen";
            alias = {
              "dff" = "difftool";
              "fap" = "fetch --all -p";
              "rm-merged" =
                "for-each-ref --format '%(refname:short)' refs/heads | grep -v master | xargs git branch -D";
              "recents" =
                "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
            };
          };
        };
      in
      {
        home.packages = [
          pkgs.difftastic
          pkgs.git-lfs
          git
        ];

        programs.mergiraf = {
          enable = true;
          enableGitIntegration = false;
          enableJujutsuIntegration = true;
        };

        programs.delta.enable = true;
        programs.delta.enableGitIntegration = false;
      };
  };
}
