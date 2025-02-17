{
  perSystem,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  commands = [
    {
      package = perSystem.self.leader;
      help = "Leader key";
    }
  ];
}
