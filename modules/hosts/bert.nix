# bert: CI runner mac, no users (kit github-runner gives the runner content).
{ yen, ... }:
{
  yen.mac.bert = {
    system = yen.system.aarch64-darwin;
  };
  yen.assembly.ci-bert = {
    kit = yen.kit.github-runner;
    roles.runner = {
      at = yen.mac.bert;
      settings.label = "macos-latest";
    };
  };
}
