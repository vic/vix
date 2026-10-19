# Packages: each system emits flake packages; content reads them back as self'.packages.
{ ren, inputs, ... }:
{
  _module.args.pkgsFor = system: inputs.nixpkgs.legacyPackages.${system.name};

  ren.channels.packages = {
    fold = ren.lib.fold.attrs;
    at = ren.kinds.system;
    to = e: e;
    into = { system, ... }: pkgs': { packages.${system.name} = pkgs'; };
  };
}
