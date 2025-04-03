{ pkgs, perSystem, ... }:
{

  home.packages = let
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

    jj-tui-wrap = drv: pkgs.stdenvNoCC.mkDerivation {
      inherit (drv) name meta;
      nativeBuildInputs = [ pkgs.makeWrapper ];
      phases = "wrap";
      wrap = ''
      makeWrapper \
        "${drv}/bin/${drv.meta.mainProgram}" \
        "$out/bin/${drv.meta.mainProgram}" \
        --prefix PATH : ${jj-for-tui}/bin
      '';
    };
  in [
    (jj-tui-wrap perSystem.self.lazyjj)
    (jj-tui-wrap perSystem.self.jj-fzf)
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
      };

    };
  };

  home.file.".config/jj/tui.toml".source = let
    toml = {
      template-aliases = {
        "format_short_id(id)" = "id.shortest()"; # default is shortest(12)
        "format_short_change_id(id)" = "format_short_id(id)";
        "format_short_signature(signature)" = "signature.email()";
        "format_timestamp(timestamp)" = "timestamp.ago()";
      };
    };
    fmt = pkgs.formats.toml {}; 
  in fmt.generate "tui.toml" toml;
}
