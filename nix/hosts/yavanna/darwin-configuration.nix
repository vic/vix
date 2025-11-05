{ inputs, ... }:
{
  flake.modules.darwin.yavanna.imports = with inputs.self.modules.darwin; [
    vic
    { users.users.vic.home = "/Users/vic"; }
  ];

}
