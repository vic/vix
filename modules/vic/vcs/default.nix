{ vic, ... }:
{
  vic.vcs.includes = [
    vic.git
    vic.jujutsu
  ];
  vic.everywhere.includes = [ vic.vcs ];
}
