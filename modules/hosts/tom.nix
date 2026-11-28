# tom: CI runner host, no users (native `yen.kits.github-runner`).
{ yen, ... }:
{
  yen.host.tom.system = yen.system.x86_64-linux;
  yen.assemblies.ci-tom = yen.kits.github-runner {
    runner = {
      at = yen.host.tom;
      settings.label = "ubuntu-latest";
    };
  };
}
