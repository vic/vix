# bert: CI runner mac, no users (the runner content is the ci-runner aspect).
{ sven, ... }:
{
  sven.mac.bert = {
    system = sven.system.aarch64-darwin;
    ghRunner = "macos-latest";
  };
}
