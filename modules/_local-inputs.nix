# override inputs with vic's development repos.
{ lib, ... }:
{

  flake-file.inputs = lib.mkIf (builtins.pathExists ../../den) {
    den.url = "path:/home/vic/hk/den";
    denful.url = "path:/home/vic/hk/denful";
    flake-aspects.url = "path:/home/vic/hk/flake-aspects";
  };

}
