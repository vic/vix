# Packages: each system emits flake packages; content reads them back from the flake's own outputs.
{ ren, ... }:
{

  ren.channels.packages = {
    fold = ren.lib.fold.attrs;
    at = ren.lib.anyOf [
      ren.kinds.system
      (ren.lib.within ren.kinds.system)
    ]; # a system, or a scope below it (a vim profile)
    to =
      e:
      ren.lib.and [
        ren.kinds.system
        (ren.lib.anyOf [
          e
          (ren.lib.has e)
        ])
      ];
    into = { system, ... }: pkgs': { packages.${system.name} = pkgs'; };
  };
}
