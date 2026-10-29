# tom: CI runner host, no users (the runner content is the ci-runner aspect).
{ yen, ... }:
{
  yen.host.tom = {
    system = yen.system.x86_64-linux;
    ghRunner = "ubuntu-latest";
  };
}
