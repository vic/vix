# bill: CI runner host, no users (the runner content is the ci-runner aspect).
{ sven, ... }:
{
  sven.host.bill = {
    system = sven.system.aarch64-linux;
    ghRunner = "ubuntu-24.04-arm";
  };
}
