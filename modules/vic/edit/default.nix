{ vic, ... }:
{
  vic.edit.includes = [
    vic.browsers
    vic.doom
    vic.editors
    vic.nvim
  ];
  vic.everywhere.includes = [ vic.edit ];
}
