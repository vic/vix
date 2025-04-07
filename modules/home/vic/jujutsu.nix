{ pkgs, perSystem, ... }:
{

  home.packages =
    let
      jj-for-tui = pkgs.stdenvNoCC.mkDerivation {
        inherit (pkgs.jujutsu) name version meta;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        phases = "wrap";
        wrap = ''
          makeWrapper ${pkgs.jujutsu}/bin/jj $out/bin/jj \
          --add-flags --config-file \
          --add-flags "~/.config/jj/tui.toml"
        '';
      };

      jj-tui-wrap =
        drv: extra:
        pkgs.stdenvNoCC.mkDerivation {
          inherit (drv) name meta;
          nativeBuildInputs = [ pkgs.makeWrapper ];
          phases = "wrap";
          wrap = ''
            makeWrapper \
              "${drv}/bin/${drv.meta.mainProgram}" \
              "$out/bin/${drv.meta.mainProgram}" \
              --prefix PATH : ${jj-for-tui}/bin \
              ${extra}
          '';
        };
    in
    [
      (jj-tui-wrap perSystem.self.lazyjj "--add-flags --jj-bin --add-flags ${jj-for-tui}/bin/jj")
      (jj-tui-wrap perSystem.self.jj-fzf "--add-flags --key-bindings")
      (jj-tui-wrap perSystem.self.jjui "")
    ];

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

        "default_log()" = "present(@) | ancestors(immutable_heads().., 2) | present(trunk())";
      };

      template-aliases = {
        "format_short_id(id)" = "id.shortest().upper()"; # default is shortest(12)
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
        push-bookmark-prefix = "vic/jj-change-";
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
      };

    };
  };

  home.file.".config/jj/tui.toml".source =
    let
      toml = {
        ui.editor = "vim";
        jj-fzf = {
          show-keys = "true";
          revsets.log = "..";
          diff-mode = "jj-diff";
        };
        template-aliases = {
          "format_short_id(id)" = "id.shortest().upper()"; # default is shortest(12)
          "format_short_change_id(id)" = "format_short_id(id)";
          "format_short_signature(signature)" = "signature.email()";
          "format_timestamp(timestamp)" = "timestamp.ago()";
        };
      };
      fmt = pkgs.formats.toml { };
    in
    fmt.generate "tui.toml" toml;

  home.file.".config/jjui/config.toml".source =
    let
      # https://github.com/idursun/jjui/wiki/Configuration
      toml = {

      };
      fmt = pkgs.formats.toml { };
    in
    fmt.generate "config.toml" toml;
}
