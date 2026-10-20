# jujutsu-ui: jj settings.
{ ren, ... }:
{
  ren.aspects.jujutsu-ui = {
    at = ren.aspects.vic-headless;
    homeManager =
      { pkgs, ... }:
      let
        diff-formatter = [
          (pkgs.lib.getExe pkgs.delta)
          "$left"
          "$right"
        ];
      in
      {
        programs.jujutsu.settings = {
          ui = {
            default-command = [
              "status"
              "--no-pager"
            ];
            inherit diff-formatter;
            diff-editor = [
              "nvim"
              "-c"
              "DiffEditor $left $right $output"
            ];
            conflict-marker-style = "git";
            movement.edit = false;
          };
          "--scope" = [
            {
              "--when".commands = [
                "diff"
                "show"
              ];
              ui.pager = pkgs.lib.getExe pkgs.delta;
              ui.diff-formatter = diff-formatter;
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
        };
      };
  };
}
