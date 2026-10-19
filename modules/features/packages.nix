# Packages: each system emits flake packages; content reads them back as self'.packages.
{ ren, inputs, ... }:
{
  _module.args.pkgsFor = system: inputs.nixpkgs.legacyPackages.${system.name};

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
