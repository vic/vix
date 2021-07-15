{ config, pkgs, lib, vix-lib, USER, HOME, ... }:
{
  _module.args = { direnv_dir = ".nix-out/direnv"; };
  imports = [ ./lorri.nix ./shell.nix ];
}
