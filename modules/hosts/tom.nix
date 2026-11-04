# tom: CI runner host, no users (kit github-runner gives the runner content).
{ yen, ... }:
{
  yen.host.tom = {
    system = yen.system.x86_64-linux;
  };
  yen.assembly.ci-tom = {
    kit = yen.kit.github-runner;
    roles.runner = {
      at = yen.host.tom;
      settings.label = "ubuntu-latest";
    };
  };
}
