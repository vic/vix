{ config, lib, pkgs, ... } @ args:

{
  nodePackages.hyp = import ./hyp args;
}
