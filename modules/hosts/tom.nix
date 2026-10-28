# tom: CI runner host, no users (the runner content is the ci-runner aspect).
{ sven, ... }:
{
  sven.host.tom = {
    system = sven.system.x86_64-linux;
    ghRunner = "ubuntu-latest";
  };
}
