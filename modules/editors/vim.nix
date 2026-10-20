# vim: editor profiles below each system, each an nvf config built by the `vim` class into packages.<profile>.
{
  ren,
  lib,
  inputs,
  ...
}:
let
  vix = ren.helpers;
  # every feature an aspect can gate on: `at = ren.lib.when (s: builtins.elem "snacks" (s.vim.features or [ ]));`
  features = builtins.filter (w: builtins.isString w && w != "") (
    builtins.split "[[:space:]]+" ''
      avante blink bufferline codecompanion conform copilot copilot-chat dropbar flash globals
      go grug-far haunt hunk jj lazy lsp lua lualine mini mini-essentials mini-files moonbit
      neo-tree noice nvim-lint persistence rust scope smartcolumn snacks snacks-extras
      snacks-header snacks-keys todo-comments toggleterm trouble tv tv-vim which-key
    ''
  );
in
{
  ren.kinds.system.below = [ ren.kinds.vim ]; # one profile scope per system (merges with topology/fleet.nix, v33)
  ren.kinds.vim = {
    features = vix.opt (lib.types.listOf (lib.types.enum features)) [ ];
    theme = vix.maybe lib.types.str; # a colorscheme name
    gui = vix.opt lib.types.bool false; # also emit packages.<name>-gui (neovide)
    aliases = vix.opt (lib.types.listOf lib.types.str) [ ]; # extra binary names
  };

  ren.aspects.vim-inputs = {
    at = ren.fleet.vix;
    flake-inputs =
      { ... }:
      {
        nvf = {
          url = "github:notashelf/nvf/969775ccc2830a70119ba8720a4cf250490a1f56";
          inputs.mnw.follows = "mnw";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        mnw.url = "github:Gerg-L/mnw/a582dbedf7c8ec7effa6939ac5bdd23b27267d1b";
      };
  };

  ren.classes.vim = {
    at = ren.kinds.vim;
    into =
      {
        vim,
        system,
        unfree,
        ...
      }:
      modules:
      let
        # a profile's aspects may allow unfree plugin deps (`unfree = allowUnfree [ .. ];`)
        pkgs =
          if unfree == { } then
            system.legacyPackages
          else
            import inputs.nixpkgs {
              system = system.name;
              config.allowUnfreePredicate = p: unfree ? ${inputs.nixpkgs.lib.getName p};
            };
        nvim = (inputs.nvf.lib.neovimConfiguration { inherit pkgs modules; }).neovim;
        names = [ vim.name ] ++ vim.aliases;
        bin = n: pkgs.writeShellScriptBin n ''exec ${nvim}/bin/nvim "$@"'';
        gui =
          n:
          pkgs.writeShellScriptBin "${n}-gui" ''exec ${pkgs.neovide}/bin/neovide --neovim-bin ${nvim}/bin/nvim "$@"'';
        join =
          suffix: f:
          pkgs.symlinkJoin {
            name = vim.name + suffix;
            paths = map f names;
          };
      in
      {
        packages = {
          ${vim.name} = join "" bin;
        }
        // lib.optionalAttrs vim.gui { "${vim.name}-gui" = join "-gui" gui; };
      };
  };
}
