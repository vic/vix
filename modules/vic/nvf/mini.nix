# vim mini: mini.nvim modules — the full set, LazyVim's essentials, nvim's mini.files explorer.
{ sven, lib, ... }:
let
  # module = setupOpts; commented-out ones are off on purpose.
  all = {
    ai = { };
    align = { };
    animate = { };
    #basics = { options.extra_ui = true; mappings.windows = true; };
    bracketed = { };
    bufremove = { };
    #clue = { };
    #colors = { };
    comment = { };
    ##completion = { };
    cursorword = { };
    diff = { };
    doc = { };
    extra = { };
    files = { };
    fuzzy = { };
    #git = { };
    hipatterns = { };
    icons = { };
    indentscope = { };
    jump = { };
    jump2d = {
      labels = "lkjhasdfgpoiuyqwertbv0987654321cnxmz";
      view.dim = true;
    };
    map = { };
    misc = { };
    move = { };
    notify = { };
    operators = { };
    pairs = { };
    #pick = { };
    #sessions = { };
    #snippets = { };
    splitjoin = { };
    statusline = { };
    surround = { };
    tabline = { };
    trailspace = { };
    visits = { };
  };
  enable = lib.mapAttrs (
    _: setupOpts: { enable = true; } // lib.optionalAttrs (setupOpts != { }) { inherit setupOpts; }
  );
in
{
  sven.aspects.vim-mini = {
    at = sven.helpers.vimHas "mini";
    nvf.vim.mini = enable all;
  };

  sven.aspects.vim-mini-essentials = {
    at = sven.helpers.vimHas "mini-essentials";
    nvf.vim.mini = enable { inherit (all) ai pairs icons; };
  };

  sven.aspects.vim-mini-files = {
    at = sven.helpers.vimHas "mini-files";
    nvf.vim = {
      mini.files = {
        enable = true;
        setupOpts.mappings = {
          close = "<ESC>";
          go_in_plus = "<CR>";
          reset = "-";
        };
      };
      keymaps = [
        {
          key = "<leader>E";
          mode = [ "n" ];
          desc = "Explore";
          action = "function() require('mini.files').open(vim.api.nvim_buf_get_name(0), false) end";
          lua = true;
        }
      ];
      luaConfigRC.mini-files-bookmarks = ''
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniFilesExplorerOpen",
          callback = function()
            MiniFiles.set_bookmark("c", vim.fn.stdpath("config"), { desc = "Config" })
            MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
            MiniFiles.set_bookmark("~", "~", { desc = "Home directory" })
          end,
        })
      '';
    };
  };
}
