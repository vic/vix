# jujutsu-revsets: jj settings.
{ ren, ... }:
{
  ren.aspects.jujutsu-revsets = {
    at = ren.aspects.vic-headless;
    homeManager = { ... }: {
      programs.jujutsu.settings = {
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
      };
    };
  };
}
