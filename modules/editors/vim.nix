# vim: editor profiles below each system, each an nvf config the `nvf` sink builds into packages.<profile>.
{
  sven,
  lib,
  inputs,
  ...
}:
let
  inherit (sven.lib) opt maybe;
  inherit (sven.helpers) listOf enum;
  # every feature an aspect can gate on: `at = sven.helpers.vimHas "snacks";`
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
  sven.kinds.system.spawns.vim = _: sven.vim; # one profile scope per system
  sven.kinds.vim = {
    fields = {
      features = opt (listOf (enum features)) [ ];
      theme = maybe lib.types.str; # a colorscheme name
      gui = opt lib.types.bool false; # also give packages.<name>-gui (neovide)
      aliases = opt (listOf lib.types.str) [ ]; # extra binary names
    };
    # not `vim`: a sink named like its kind loses the `vim` arg to the kind. An element is an nvf module.
    sinks.nvf.packages =
      {
        vim,
        system,
        unfree,
        nvf,
        ...
      }:
      let
        # a profile's aspects may allow unfree plugin deps (`unfree = sven.helpers.allowUnfree [ .. ];`)
        pkgs =
          if unfree == { } then
            system.legacyPackages
          else
            import inputs.nixpkgs {
              system = system.name;
              config.allowUnfreePredicate = p: unfree ? ${inputs.nixpkgs.lib.getName p};
            };
        nvim = (inputs.nvf.lib.neovimConfiguration { inherit pkgs; modules = nvf; }).neovim;
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
        ${vim.name} = join "" bin;
      }
      // lib.optionalAttrs vim.gui { "${vim.name}-gui" = join "-gui" gui; };
  };

  # a sink with no elements has no receiver, so no forward: a bare profile (vscode-vim) still builds
  sven.aspects.vim-profile = {
    at = sven.kinds.vim;
    nvf = { };
  };

  sven.aspects.vim-inputs = {
    at = sven.fleet.vix;
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
