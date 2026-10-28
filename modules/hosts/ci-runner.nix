# ci-runner: a machine with a GitHub runner label (ghRunner) is a bare CI runner, no users; ci.yml and the invariants read the same datum.
{ sven, ... }:
{
  sven.aspects.ci-runner = {
    at = sven.lib.all [
      sven.helpers.machines
      (s: s.ghRunner != null)
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
}
