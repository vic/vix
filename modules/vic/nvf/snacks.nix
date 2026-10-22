# vim snacks: snacks.nvim, vic's header, picker keymaps, and the nvim profile's dashboard + toggles.
{ ren, ... }:
let
  on = {
    enabled = true;
  };
in
{
  ren.aspects.vim-snacks = {
    at = ren.lib.when (s: builtins.elem "snacks" (s.vim.features or [ ]));
    vim.vim.utility.snacks-nvim = {
      enable = true;
      setupOpts = {
        bigfile = on;
        dashboard = on;
        explorer = on;
        indent = on;
        input = on;
        notifier = on // {
          timeout = 3000;
        };
        picker = on;
        quickfile = on;
        scope = on;
        scroll = on;
        statuscolumn = on;
        words = on;
      };
    };
  };

  ren.aspects.vim-snacks-header = {
    at = ren.lib.when (s: builtins.elem "snacks-header" (s.vim.features or [ ]));
    vim.vim.utility.snacks-nvim.setupOpts.dashboard.preset.header = builtins.readFile ./header.txt;
  };

  ren.aspects.vim-snacks-keys = {
    at = ren.lib.when (s: builtins.elem "snacks-keys" (s.vim.features or [ ]));
    vim = import ./_keys.nix;
  };

  ren.aspects.vim-snacks-extras = {
    at = ren.lib.when (s: builtins.elem "snacks-extras" (s.vim.features or [ ]));
    vim =
      { lib, ... }:
      {
        vim.utility.snacks-nvim.setupOpts.dashboard.sections = [
          {
            icon = " ";
            title = "Recent Files";
            section = "recent_files";
            indent = 1;
            height = 20;
          }
          {
            icon = " ";
            title = "Projects";
            section = "projects";
            indent = 1;
          }
          {
            icon = " ";
            title = "jj status";
            section = "terminal";
            enabled = lib.generators.mkLuaInline "function() return Snacks.git.get_root() ~= nil end";
            cmd = "jj --ignore-working-copy status --no-pager";
            ttl = 300;
            indent = 0;
          }
        ];
        vim.luaConfigRC.snacks-toggles = lib.nvim.dag.entryAfter [ "pluginConfigs" ] ''
          _G.dd = function(...) Snacks.debug.inspect(...) end
          _G.bt = function() Snacks.debug.backtrace() end
          vim.print = _G.dd
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.dim():map("<leader>uD")
        '';
      };
  };
}
