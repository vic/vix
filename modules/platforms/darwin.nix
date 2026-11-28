# nix-darwin: the mac kind and the darwin sink; os fans out to darwin.
{
  yen,
  reduce,
  ...
}:
{
  yen.kinds.mac = {
    spawns.user = yen.helpers.usersOf;
    sinks = {
      darwin = {
        reduce = reduce.modules;
        allowOrphan = true;
        into.out =
          { mac, darwin, ... }:
          {
            darwinConfigurations.${mac.name} = mac.channel.darwin.lib.darwinSystem {
              system = mac.system.name;
              modules = darwin;
            };
          };
      };
      os.into.darwin = { os, ... }: yen.lib.many os;
    };
  };
}
