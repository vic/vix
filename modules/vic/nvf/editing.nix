# vim editing: editor options/tools, keymap help, motions, search-replace, sessions, todos.
{ yen, ... }:
{
  yen.aspects.vim-globals = {
    at = yen.helpers.vimHas "globals";
    nvf =
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

  yen.aspects.vim-which-key = {
    at = yen.helpers.vimHas "which-key";
    nvf.vim.binds.whichKey = {
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

  yen.aspects.vim-flash = {
    at = yen.helpers.vimHas "flash";
    nvf.vim.utility.motion.flash-nvim.enable = true;
  };

  yen.aspects.vim-grug-far = {
    at = yen.helpers.vimHas "grug-far";
    nvf.vim.utility.grug-far-nvim.enable = true;
  };

  yen.aspects.vim-todo-comments = {
    at = yen.helpers.vimHas "todo-comments";
    nvf.vim.notes.todo-comments.enable = true;
  };

  yen.aspects.vim-persistence = {
    at = yen.helpers.vimHas "persistence";
    nvf =
      { pkgs, ... }:
      {
        vim.extraPlugins.persistence = {
          package = pkgs.vimPlugins.persistence-nvim;
          setup = "require('persistence').setup({})";
        };
      };
  };

  yen.aspects.vim-haunt = {
    at = yen.helpers.vimHas "haunt";
    nvf =
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
