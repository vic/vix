{ pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;

    # See https://jj-vcs.github.io/jj/v0.17.0/config
    settings = {
      user.name = "Victor Borja";
      user.email = "vborja@apache.org";

      revset-aliases = {
        "trunk()" = "main@origin";

        # commits on working-copy compared to `trunk`
        "compared_to_trunk()" = "(trunk()..@):: | (trunk()..@)-";

        # immutable heads:
        # main and not mine commits.
        "immutable_heads()" = "trunk() | (trunk().. & ~mine())";
      };

      template-aliases = {
        "format_short_id(id)" = "id.shortest(7)"; # default is shortest(12)
        "format_short_change_id(id)" = "format_short_id(id)";
        "format_short_signature(signature)" = "signature.email()";
      };

      ui = {
        default-command = [
          "l"
          "--no-pager"
          "--reversed"
        ];
        diff.tool = [
          (pkgs.lib.getExe pkgs.difftastic)
          "--color=always"
          "$left"
          "$right"
        ];
        # pager = ":builtin";
        # editor = "nvim";
        merge-editor = "vscode"; # meld
      };

      signing = {
        behaviour = "own";
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
      };

      git = {
        push-bookmark-prefix = "vic/change-";
      };

      aliases = {
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

        n = [ "new" ];
        d = [ "describe" ];
        b = [ "bookmark" ];
        s = [ "squash" ];
        r = [ "rebase" ];
        e = [ "edit" ];
        A = [ "abbandon" ];
        U = [ "undo" ];
      };

    };
  };
}
