{ vic, ... }:
{
  vic.sys.includes = [
    vic.dots
    vic.fonts
    vic.secrets
    vic.ssh
    vic.system
  ];
  vic.everywhere.includes = [ vic.sys ];
}
