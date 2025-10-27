{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.vm = pkgs.writeShellApplication {
        name = "vm";
        text = ''
          ${inputs.self.nixosConfigurations.nargun-vm.config.system.build.vm}/bin/run-nargun-vm-vm "$@"
        '';
      };
    };
}
