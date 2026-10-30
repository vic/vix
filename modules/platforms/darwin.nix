# nix-darwin: the mac kind and the darwin sink; os fans out to darwin.
{ yen, ... }:
{
  yen.kinds.mac = {
    fields = yen.kinds.machine.fields;
    spawns.user = yen.helpers.usersOf;
    sinks = {
      darwin.out = yen.lib.batteries.darwin.system {
        from = yen.kinds.mac.sinks.darwin;
        darwinSystem = m: m.channel.darwin.lib.darwinSystem;
        system = m: m.system.name;
      };
      os.darwin = { os, ... }: { imports = os; };
    };
  };
}
