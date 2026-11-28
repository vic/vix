# bert: CI runner mac, no users (native `yen.kits.github-runner`).
{ yen, ... }:
{
  yen.mac.bert.system = yen.system.aarch64-darwin;
  yen.assemblies.ci-bert = yen.kits.github-runner {
    runner = {
      at = yen.mac.bert;
      settings.label = "macos-latest";
    };
  };
}
