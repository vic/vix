# nix-darwin: the mac kind and the darwin sink; os fans out to darwin.
{ yen, ... }:
{
  yen.kinds.mac = {
    fields = yen.kinds.machine.fields;
    spawns.user = yen.helpers.usersOf;
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
