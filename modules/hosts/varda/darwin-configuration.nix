{ inputs, ... }:
{
  flake.modules.darwin.varda.imports = with inputs.self.modules.darwin; [
    vic
    { users.users.vic.home = "/Users/vic"; }
  ];
}
