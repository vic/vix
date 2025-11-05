{ __findFile, ... }:
{
  den.hosts.x86_64-linux.nargun.users.vic.aspect = "oeiuwq";
  den.hosts.x86_64-linux.nargun-vm.users.vic.aspect = "oeiuwq";

  den.aspects = {
    oeiuwq.includes = [ <my/user> ];

    nargun.includes = [ <my/workstation/hw> ];
    nargun-vm.includes = [ <my/workstation/vm> ];
  };
}
