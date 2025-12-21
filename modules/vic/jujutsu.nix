# https://oppi.li/posts/configuring_jujutsu/
# https://github.com/jj-vcs/jj/discussions/5812
# https://gist.github.com/thoughtpolice/8f2fd36ae17cd11b8e7bd93a70e31ad6
{ inputs, ... }:
{
  flake-file.inputs.jjui.url = "github:idursun/jjui";

  vic.jujutsu.homeManager =
    { pkgs, ... }:
    let
      jjui = inputs.jjui.packages.${pkgs.system}.jjui;
      jjui-wrapped = pkgs.writeShellApplication {
        name = "jjui";
        text = ''
          # ask for password if key is not loaded, before jjui
          ssh-add -l || ssh-add
          ${pkgs.lib.getExe jjui} "$@"
        '';
      };
    in
    {
      home.packages = [
        pkgs.lazyjj
        pkgs.jj-fzf
        jjui-wrapped
      ];

      programs.jujutsu =
        let
          diff-formatter = [
            (pkgs.lib.getExe pkgs.difftastic)
            "--color=always"
            "$left"
            "$right"
          ];
        in
        {
          enable = true;

          # See https://jj-vcs.github.io/jj/v0.17.0/config
          settings = {
            user.name = "Victor Borja";
            user.email = "vborja@apache.org";

            revsets.log = "default()";

            revset-aliases = {
              "trunk()" = "main@origin";

              # commits on working-copy compared to `trunk`
              "compared_to_trunk()" = "(trunk()..@):: | (trunk()..@)-";

              # immutable heads:
              # main and not mine commits.
              # "immutable_heads()" = "trunk() | (trunk().. & ~mine())";
              "immutable_heads()" = "builtin_immutable_heads() | remote_bookmarks()";

              "closest_bookmark(to)" = "heads(::to & bookmarks())";

              # jjui default
              "default_log()" = "present(@) | ancestors(immutable_heads().., 2) | present(trunk())";

              "default()" = "coalesce(trunk(),root())::present(@) | ancestors(visible_heads() & recent(), 2)";

              "recent()" = "committer_date(after:'1 week ago')";
            };

            template-aliases = {
              "format_short_id(id)" = "id.shortest().upper()"; # default is shortest(12)
              "format_short_change_id(id)" = "format_short_id(id)";
              "format_short_signature(signature)" = "signature.email()";
              "format_timestamp(timestamp)" = "timestamp.ago()";
            };

            "--scope" = [
              {
                "--when".commands = [
                  "diff"
                  "show"
                ];
                ui.diff-formatter = diff-formatter;
              }
              # {
              #   "--when".repositories = [ "~/hk/jjui" ];
              #   revsets.log = "default()";
              #   revset-aliases = {
              #     "trunk()" = "main@idursun";
              #     "yc" = "remote_bookmarks('', 'exact:yc')";
              #     "vic" = "remote_bookmarks('', 'exact:vic')";
              #     "idursun" = "remote_bookmarks('', 'exact:idursun')";
              #     "default()" =
              #       "coalesce( trunk(), root() )::present(@) | ancestors(visible_heads() & recent(), 2) | idursun | vic";
              #   };
              #   aliases = {
              #     "n" = [
              #       "new"
              #       "main@idursun"
              #     ];
              #   };
              # }
            ];

            ui = {
              default-command = [
                "log" 
                "--no-pager" 
                "--reversed" 
                "--stat" 
                "--template" 
                "builtin_log_compact_full_description"
                "--limit"
                "3"
              ];
              inherit diff-formatter;
              # pager = "diffnav";
              editor = "nvim";
              diff-editor = "meld-3";
              merge-editor = "meld";
              conflict-marker-style = "git";
              movement.edit = false;
            };

            signing = {
              behaviour = "own";
              backend = "ssh";
              key = "~/.ssh/id_ed25519.pub";
            };

            templates = {
              git_push_bookmark = "vic/jj-change-";
            };

            aliases = {
              tug = [
                "bookmark"
                "move"
                "--from"
                "closest_bookmark(@-)"
                "--to"
                "@-"
              ];
              lr = [
                "log"
                "-r"
                "default() & recent()"
              ];

              s = [ "show" ];

              sq = [
                "squash"
                "-i"
              ];
              sU = [
                "squash"
                "-i"
                "-f"
                "@+"
                "-t"
                "@"
              ];
              su = [
                "squash"
                "-i"
                "-f"
                "@"
                "-t"
                "@+"
              ];
              sd = [
                "squash"
                "-i"
                "-f"
                "@"
                "-t"
                "@-"
              ];
              sD = [
                "squash"
                "-i"
                "-f"
                "@-"
                "-t"
                "@"
              ];

              l = [
                "log"
                "-r"
                "compared_to_trunk()"
                "--config"
                "template-aliases.'format_short_id(id)'='id.shortest().upper()'"
                "--config"
                "template-aliases.'format_short_change_id(id)'='id.shortest().upper()'"
                "--config"
                "template-aliases.'format_timestamp(timestamp)'='timestamp.ago()'"
              ];

              # like git log, all visible commits in the repo
              ll = [
                "log"
                "-r"
                ".."
              ];
            };

          };
        };

      home.file.".config/jjui/config.toml".source =
        let
          # https://github.com/idursun/jjui/wiki/Configuration
          toml = {
            leader.e.help = "Edit file";
            leader.e.send = [
              "$"
              "jj edit $change_id && $VISUAL $file"
              "enter"
            ];
          };
          fmt = pkgs.formats.toml { };
        in
        fmt.generate "config.toml" toml;
    };
}
