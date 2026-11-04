# bill: CI runner host, no users (kit github-runner gives the runner content).
{ yen, ... }:
{
  yen.host.bill = {
    system = yen.system.aarch64-linux;
  };
  yen.assembly.ci-bill = {
    kit = yen.kit.github-runner;
    roles.runner = {
      at = yen.host.bill;
      settings.label = "ubuntu-24.04-arm";
    };
  };
}
