{ vic, ... }:
{
  vic.shell.includes = [
    vic.cli-tools
    vic.direnv
    vic.fish
    vic.terminals
  ];
  vic.everywhere.includes = [ vic.shell ];
}
