{
  vix,
  vic,
  den,
  inputs,
  ...
}:
let
  includes = [
    den.provides.define-user
    den.provides.primary-user
    (den.provides.user-shell "fish")
    (vix.autologin)
    (vix.nix-index)
    (vix.nix-registry)
    (vix.macos-keys)
  ];
in
{
  den.aspects.vic.user.description = "El Oeiuwq";
  den.aspects.vic.includes = [ vic.everywhere ];

  den.aspects.nargun.nixos.documentation.enable = false;
  den.aspects.nargun.includes = [
    (den.provides.unfree [ "vscode" ])
  ];

  vic.everywhere = den.lib.parametric { inherit includes; };
}
