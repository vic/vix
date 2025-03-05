{ ... }:
{
  home.file.".config" = {
    recursive = true;
    source = ./dots/config;
  };
  home.file.".ssh" = {
    recursive = true;
    source = ./dots/ssh;
  };

}
