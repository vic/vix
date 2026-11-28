# bill: CI runner host, no users (native `yen.kits.github-runner`).
{ yen, ... }:
{
  yen.host.bill.system = yen.system.aarch64-linux;
  yen.assemblies.ci-bill = yen.kits.github-runner {
    runner = {
      at = yen.host.bill;
      settings.label = "ubuntu-24.04-arm";
    };
  };
}
