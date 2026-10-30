# exports: vic's home as `homeModules.<name>` for other flakes (swarsel exports, Den moduleOf).
# An export scope spawns the user outside any machine or home: only content that needs no place holds
# there (vic-headless, vic-full); vic-gui and vic-secrets do not (no graphical, no trusted role).
{ yen, ... }:
{
  yen.kinds.fleet.spawns.export = _: yen.export;
  yen.kinds.export = {
    fields.user = yen.kinds.user;
    spawns.user = s: { ${s.user.name} = s.user; };
    # the user's own homeManager sink holds only within a machine or home, so here its elements come up to this one
    sinks.homeManager.out = yen.lib.batteries.exports.modules {
      from = yen.kinds.export.sinks.homeManager;
      output = "homeModules";
    };
  };
  yen.export.vic.user = yen.user.vic;
}
