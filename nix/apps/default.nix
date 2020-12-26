{ config, lib, pkgs, sources, ... } @ args:

{
  iterm2 = import ./iterm2 args;
  firefox-developer = import ./firefox-developer args;
  tor-browser = import ./tor-browser args;
  beaker-browser = import ./beaker-browser args;
  flux = import ./flux args;
  keybase = import ./keybase args;
  jetbrains.idea-community = import ./idea-community args;
}
