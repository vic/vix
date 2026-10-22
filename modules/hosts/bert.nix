# bert: CI runner mac, no users.
{ ren, ... }:
{
  ren.mac.bert.system = ren.system.aarch64-darwin;

  ren.aspects.bert-runner.darwin = {
    users.users.runner.home = "/Users/runner";
    system.primaryUser = "runner";
  };
  ren.aspects.bert = {
    at = ren.mac.bert;
    includes = [ ren.aspects.bert-runner ];
  };
}
