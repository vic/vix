# vim: editor profiles below each system, ref-typed `vimFeature` tags (zero string enums!).
{
  yen,
  types,
  reduce,
  lib,
  inputs,
  ...
}:
let
  featureNames = builtins.filter (w: builtins.isString w && w != "") (
    builtins.split "[[:space:]]+" ''
      avante blink bufferline codecompanion conform copilot copilot-chat dropbar flash globals
      go grug-far haunt hunk jj lazy lsp lua lualine mini mini-essentials mini-files moonbit
      neo-tree noice nvim-lint persistence rust scope smartcolumn snacks snacks-extras
      snacks-header snacks-keys todo-comments toggleterm trouble tv tv-vim which-key
    ''
  );
  buildVimPkgs =
    vim: system: unfree: nvf:
    (
      pkgs:
      (
        nvim:
        (
          names:
          (
            join:
            {
              ${vim.name} = join "" (n: pkgs.writeShellScriptBin n ''exec ${nvim}/bin/nvim "$@"'');
            }
            // lib.optionalAttrs vim.gui {
              "${vim.name}-gui" = join "-gui" (
                n:
                pkgs.writeShellScriptBin "${n}-gui" ''exec ${pkgs.neovide}/bin/neovide --neovim-bin ${nvim}/bin/nvim "$@"''
              );
            }
          )
            (
              suffix: f:
              pkgs.symlinkJoin {
                name = vim.name + suffix;
                paths = map f names;
              }
            )
        )
          ([ vim.name ] ++ vim.aliases)
      )
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = nvf;
        }).neovim
    )
      (
        if unfree == [ ] then
          system.legacyPackages
        else
          import inputs.nixpkgs {
            system = system.name;
            config.allowUnfreePredicate = p: builtins.elem (inputs.nixpkgs.lib.getName p) unfree;
          }
      );
in
{
  # Ref-typed vim features kind (zero strings!)
  yen.kinds.vimFeature = { };
  yen.vimFeature = lib.genAttrs featureNames (_: { });

  yen.kinds.system.spawns.vim = _: yen.vim;
  yen.kinds.vim = {
    fields = {
      features = types.opt (types.listOf yen.kinds.vimFeature) [ ];
      theme = types.maybe types.str;
      gui = types.opt types.bool false;
      aliases = types.opt (types.listOf types.str) [ ];
    };
    sinks.nvf = {
      reduce = reduce.modules;
      into.packages =
        {
          vim,
          system,
          unfree ? [ ],
          nvf,
          ...
        }:
        buildVimPkgs vim system unfree nvf;
    };
  };

  yen.aspects.vim-profile = {
    at = yen.kinds.vim;
    nvf = { };
  };

  yen.aspects.vim-inputs = {
    at = yen.root;
    flake-file.inputs = {
      nvf = {
        url = "github:notashelf/nvf";
        inputs.mnw.follows = "mnw";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      mnw.url = "github:Gerg-L/mnw";
    };
  };
}
