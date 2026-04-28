# See https://github.com/jj-vcs/jj/discussions/5812
{ vic, ... }:
let
  jj-settings =
    { pkgs }:
    {
      user.name = "Victor Borja";
      user.email = "vborja@apache.org";
      revsets.log = "default()";
      revset-aliases = {
        "trunk()" = "main@origin";
        "compared_to_trunk()" = "(trunk()..@):: | (trunk()..@)-";
        "immutable_heads()" = "builtin_immutable_heads() | remote_bookmarks()";
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
        "default_log()" = "present(@) | ancestors(immutable_heads().., 2) | present(trunk())";
        "default()" = "coalesce(trunk(),root())::present(@) | ancestors(visible_heads() & recent(), 2)";
        "recent()" = "committer_date(after:'1 week ago')";
      };
      template-aliases = {
        "format_short_id(id)" = "id.shortest().upper()";
        "format_short_change_id(id)" = "format_short_id(id)";
        "format_short_signature(signature)" = "signature.email()";
        "format_timestamp(timestamp)" = "timestamp.ago()";
      };
      "--scope" = jj-scopes { inherit pkgs; };
      ui = jj-ui { inherit pkgs; };
      signing = {
        behaviour = "own";
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
      };
      aliases = jj-aliases;
    };

  jj-diff-formatter =
    { pkgs }:
    [
      (pkgs.lib.getExe pkgs.delta)
      "$left"
      "$right"
    ];

  jj-ui =
    { pkgs }:
    {
      default-command = [
        "status"
        "--no-pager"
      ];
      diff-formatter = jj-diff-formatter { inherit pkgs; };
      diff-editor = [
        "nvim"
        "-c"
        "DiffEditor $left $right $output"
      ];
      conflict-marker-style = "git";
      movement.edit = false;
    };

  jj-scopes =
    { pkgs }:
    [
      {
        "--when".commands = [
          "diff"
          "show"
        ];
        ui.pager = (pkgs.lib.getExe pkgs.delta);
        ui.diff-formatter = jj-diff-formatter { inherit pkgs; };
      }
      {
        "--when".repositories = [ "~/hk/jjui" ];
        revsets.log = "default()";
        revset-aliases = {
          "trunk()" = "main@idursun";
          "vic" = "remote_bookmarks('', 'vic')";
          "idursun" = "remote_bookmarks('', 'idursun')";
          "default()" =
            "coalesce( trunk(), root() )::present(@) | ancestors(visible_heads() & recent(), 2) | idursun | vic";
        };
        aliases.n = [
          "new"
          "main@idursun"
        ];
      }
    ];

  jj-aliases = {
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
    ll = [
      "log"
      "-r"
      ".."
    ];
  };
in
{
  flake-file.inputs.majjit.url = "github:anthrofract/majjit";
  flake-file.inputs.jjui.url = "github:idursun/jjui";

  vic.everywhere.includes = [ vic.jujutsu ];
  vic.jujutsu.homeManager =
    { pkgs, inputs', ... }:
    let
      jjui = inputs'.jjui.packages.jjui;
      jjui-wrapped = pkgs.writeShellApplication {
        name = "jjui";
        text = ''
          # ask for password if key is not loaded, before jjui
          ssh-add -l || ssh-add
          ${pkgs.lib.getExe jjui} "$@"
        '';
      };

      majjit = inputs'.jjui.packages.jjui;
      majjit-wrapped = pkgs.writeShellApplication {
        name = "majjit";
        text = ''
          # ask for password if key is not loaded, before jjui
          ssh-add -l || ssh-add
          ${pkgs.lib.getExe majjit} "$@"
        '';
      };
    in
    {
      home.packages = [ jjui-wrapped majjit-wrapped ];
      programs.jujutsu = {
        enable = true;
        settings = jj-settings { inherit pkgs; };
      };
      # home.file.".config/jjui/config.toml".source = fmt.generate "config.toml" jjui-toml;
    };
}
