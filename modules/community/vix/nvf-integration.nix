{
  den,
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs.nvf.url = "github:notashelf/nvf";

  den.lib.nvf.package =
    pkgs: vimAspect: ctx:
    (inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [ (den.lib.nvf.module vimAspect ctx) ];
    }).neovim;

  den.lib.nvf.module =
    vimAspect: ctx:
    let
      vimClass =
        { aspect-chain }:
        den._.forward {
          each = lib.singleton true;
          fromClass = _: "vim";
          intoClass = _: "nvf";
          intoPath = _: [ "vim" ];
          fromAspect = _: lib.head aspect-chain;
          adaptArgs = lib.id;
        };

      vimOpts.nvf = _: {
        imports = [
          (lib.mkAliasOptionModule [ "vim" "opts" ] [ "vim" "options" ])
        ];
      };

      aspect = den.lib.parametric.fixedTo ctx {
        includes = [
          vimClass
          vimAspect
          vimOpts
        ];
      };

      module = den.lib.aspects.resolve "nvf" [ aspect ] aspect;
    in
    module;
}
