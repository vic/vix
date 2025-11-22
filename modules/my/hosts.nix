{ __findFile, inputs, ... }:
{
  den.hosts.x86_64-linux.nargun.users.vic.aspect = "oeiuwq";
  den.hosts.x86_64-linux.nargun-vm.users.vic.aspect = "oeiuwq";

  den.homes.x86_64-linux.vic = {
    aspect = "oeiuwq";
    instantiate = { pkgs, modules }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs modules;
	extraSpecialArgs.osConfig = inputs.self.nixosConfiguration.nargun.config;
      };
  };

  den.aspects = {
    oeiuwq.includes = [ <my/user> ];

    nargun.includes = [ <my/workstation/hw> ];
    nargun-vm.includes = [ <my/workstation/vm> ];
  };
}
