# vim editing: editor options/tools, keymap help, motions, search-replace, sessions, todos.
{ ren, ... }:
{
  ren.aspects.vim-globals = {
    at = ren.lib.when (s: builtins.elem "globals" (s.vim.features or [ ]));
    vim =
      { pkgs, ... }:
      {
        vim.extraPackages = [
          pkgs.ripgrep
          pkgs.fd
          pkgs.fzf
          pkgs.python3
          pkgs.nodejs
          pkgs.sqlite
        ];
        vim.options = {
          expandtab = true;
          tabstop = 2;
          shiftwidth = 2;
          wrap = false;
        };
      };
  };

  ren.aspects.vim-which-key = {
    at = ren.lib.when (s: builtins.elem "which-key" (s.vim.features or [ ]));
    vim.vim.binds.whichKey = {
      enable = true;
      setupOpts = {
        delay = 550;
        preset = "helix";
        keys = {
          scroll_up = "<c-p>";
          scroll_down = "<c-n>";
        };
      };
    };
  };

  ren.aspects.vim-flash = {
    at = ren.lib.when (s: builtins.elem "flash" (s.vim.features or [ ]));
    vim.vim.utility.motion.flash-nvim.enable = true;
  };

  ren.aspects.vim-grug-far = {
    at = ren.lib.when (s: builtins.elem "grug-far" (s.vim.features or [ ]));
    vim.vim.utility.grug-far-nvim.enable = true;
  };

  ren.aspects.vim-todo-comments = {
    at = ren.lib.when (s: builtins.elem "todo-comments" (s.vim.features or [ ]));
    vim.vim.notes.todo-comments.enable = true;
  };

  ren.aspects.vim-persistence = {
    at = ren.lib.when (s: builtins.elem "persistence" (s.vim.features or [ ]));
    vim =
      { pkgs, ... }:
      {
        vim.extraPlugins.persistence = {
          package = pkgs.vimPlugins.persistence-nvim;
          setup = "require('persistence').setup({})";
        };
      };
  };

  ren.aspects.vim-haunt = {
    at = ren.lib.when (s: builtins.elem "haunt" (s.vim.features or [ ]));
    vim =
      { pkgs, ... }:
      {
        vim.extraPlugins.haunt = {
          package = pkgs.vimUtils.buildVimPlugin {
            pname = "haunt.nvim";
            version = "unstable-5f96968";
            src = pkgs.fetchFromSourcehut {
              owner = "~adigitoleo";
              repo = "haunt.nvim";
              rev = "5f96968844f77fef4756df0f14b9d8e9077691e0";
              hash = "sha256-ePf5YnxKqfusLKD4K8wGE6kCAHYmf3KOB2wqmMAEO+4=";
            };
          };
          setup = "require('haunt').setup({})";
        };
      };
  };
}
