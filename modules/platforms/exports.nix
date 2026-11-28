# exports: vic's home as `homeModules.<name>` for other flakes.
{
  yen,
  reduce,
  ...
}:
{
  yen.kinds.root.spawns.export = _: yen.export;
  yen.kinds.export = {
    fields.user = yen.kinds.user;
    spawns.user = s: { ${s.user.name} = s.user; };
    sinks.homeManager = {
      reduce = reduce.modules;
      into.out =
        { export, homeManager, ... }:
        {
          homeModules.${export.name}.imports = homeManager;
        };
    };
  };
  yen.export.vic.user = yen.user.vic;
}
