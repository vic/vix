# vim langs: lsp + treesitter, languages (rust via rustaceanvim), completion, format, lint, diagnostics list.
{ yen, ... }:
{
  yen.aspects.vim-lsp = {
    at = yen.helpers.vimHas "lsp";
    nvf.vim = {
      lsp.enable = true;
      treesitter.enable = true;
      languages.enableTreesitter = true;
    };
  };

  yen.aspects.vim-lua = {
    at = yen.helpers.vimHas "lua";
    nvf.vim.languages.lua.enable = true;
  };

  yen.aspects.vim-go = {
    at = yen.helpers.vimHas "go";
    nvf.vim.languages.go.enable = true;
  };

  yen.aspects.vim-rust = {
    at = yen.helpers.vimHas "rust";
    nvf.vim = {
      languages.rust = {
        enable = true;
        lsp.enable = false; # rustaceanvim runs its own rust-analyzer
        extensions.rustaceanvim.enable = true;
      };
      luaConfigRC.rust-keys = ''
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "rust",
          callback = function(ev)
            local o = { silent = true, buffer = ev.buf }
            vim.keymap.set("n", "<leader>a", function() vim.cmd.RustLsp("codeAction") end, o)
            vim.keymap.set("n", "K", function() vim.cmd.RustLsp({ "hover", "actions" }) end, o)
          end,
        })
      '';
    };
  };

  yen.aspects.vim-blink = {
    at = yen.helpers.vimHas "blink";
    nvf.vim.autocomplete.blink-cmp = {
      enable = true;
      friendly-snippets.enable = true;
      setupOpts = {
        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
        fuzzy.implementation = "prefer_rust_with_warning";
        cmdline.completion.menu.auto_show = true;
      };
    };
  };

  yen.aspects.vim-conform = {
    at = yen.helpers.vimHas "conform";
    nvf.vim.formatter.conform-nvim.enable = true;
  };

  yen.aspects.vim-nvim-lint = {
    at = yen.helpers.vimHas "nvim-lint";
    nvf.vim.diagnostics.nvim-lint.enable = true;
  };

  yen.aspects.vim-trouble = {
    at = yen.helpers.vimHas "trouble";
    nvf.vim.lsp.trouble.enable = true;
  };
}
