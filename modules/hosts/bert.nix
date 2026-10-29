# bert: CI runner mac, no users (the runner content is the ci-runner aspect).
{ yen, ... }:
{
  yen.mac.bert = {
    system = yen.system.aarch64-darwin;
    ghRunner = "macos-latest";
  };
}
