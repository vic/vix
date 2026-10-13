{ vic, ... }:
{
  vic.dev.includes = [
    vic.dev-tools
    vic.nix
    vic.sec-ops
  ];
  vic.everywhere.includes = [ vic.dev ];
}
