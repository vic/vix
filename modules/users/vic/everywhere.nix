{
  vix,
  vic,
  den,
  inputs,
  ...
}:
let
  everywhere.description = ''
    This aspect is vic's user base environment
    on every host where vic exists.
  '';

  everywhere.__functor = den.lib.parametric;
  everywhere.includes = [
    den.provides.primary-user
    (den.provides.user-shell "fish")
    (vix.autologin)
    (vix.nix-index)
    (vix.nix-registry)
    (vix.macos-keys)
  ];
in
{
  vic = { inherit everywhere; };
  den.aspects.vic.includes = [ vic.everywhere ];
}
