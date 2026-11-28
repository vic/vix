# Native Yen kit `github-runner`: bare GitHub Actions runner claiming its system on the root `runners` sink.
{
  yen,
  at,
  types,
  ...
}:
{
  yen.kits.github-runner.roles.runner = {
    settings.label = types.str;
    runners =
      { settings, machine, ... }:
      [
        {
          system = machine.system.name;
          machine = machine.name;
          inherit (settings) label;
        }
      ];
    nixos = {
      boot.loader.grub.enable = false;
      fileSystems."/".device = "/dev/null";
      fileSystems."/".fsType = "auto";
      users.users.runner.isNormalUser = true;
    };
    darwin = {
      users.users.runner.home = "/Users/runner";
      system.primaryUser = "runner";
    };
  };

  yen.aspects.ci-runner.at = at.all [
    yen.kinds.machine
    yen.kits.github-runner.roles.runner
  ];
}
