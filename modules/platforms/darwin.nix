# nix-darwin: the mac kind and the darwin sink; os fans out to darwin.
{ sven, ... }:
{
  sven.kinds.mac = {
    fields = sven.kinds.machine.fields;
    spawns.user = sven.helpers.usersOf;
    sinks = {
      darwin.out =
        { mac, darwin, ... }:
        {
          darwinConfigurations.${mac.name} = mac.channel.darwin.lib.darwinSystem {
            system = mac.system.name;
            modules = darwin;
          };
        };
      os.darwin = { os, ... }: { imports = os; };
    };
  };
}
