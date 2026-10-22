# jujutsu-aliases: jj settings.
{ ren, ... }:
{
  ren.aspects.jujutsu-aliases = {
    at = ren.aspects.vic-headless;
    homeManager = { ... }: {
      programs.jujutsu.settings.aliases = {
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
    };
  };
}
