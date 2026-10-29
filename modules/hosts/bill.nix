# bill: CI runner host, no users (the runner content is the ci-runner aspect).
{ yen, ... }:
{
  yen.host.bill = {
    system = yen.system.aarch64-linux;
    ghRunner = "ubuntu-24.04-arm";
  };
}
